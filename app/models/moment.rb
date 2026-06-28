# == Schema Information
#
# Table name: moments
#
#  id             :string           not null, primary key
#  captured_at    :datetime
#  comments_count :integer          default(0), not null
#  likes_count    :integer          default(0), not null
#  type           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  album_id       :string           not null
#  uploader_id    :string           not null
#
class Moment < ApplicationRecord
  belongs_to :album
  belongs_to :uploader, class_name: "User", inverse_of: :moments

  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :file

  validate :file_present, on: :create

  scope :chronologic, -> { order(:captured_at, :id) }
  # captured_at is set only once analysis + warming finish, so its presence is the "ready" flag.
  scope :ready, -> { where.not(captured_at: nil) }
  scope :pending, -> { where(captured_at: nil) }
  # Moments whose attached file blob has this MD5 checksum (populated at direct-upload time) —
  # used to stop the same file being added to an album twice.
  scope :with_checksum, ->(checksum) { joins(file_attachment: :blob).where(active_storage_blobs: {checksum:}) }

  broadcasts_refreshes_to :album

  # Runs inside Active Storage's AnalyzeJob (declared per STI subclass in Photo/Video, since the
  # gem's callback registry isn't inherited).
  def after_file_analyzed(blob)
    [[400, nil], [800, nil]].each do |width, height|
      file.blob.representation(resize_to_limit: [width, height], format: :webp).processed
    end
  ensure
    # Setting captured_at both sorts the moment and reveals it in the grid, so do it *after* warming
    # — a moment is only shown once its representation exists (else a request could race a video
    # poster). In `ensure` so a warming failure still reveals the upload (degraded thumbnail) instead
    # of hiding it forever; the error still propagates (seed fails loudly, prod logs the job). Keep an
    # already-set value (seeds), then the file's own capture time, else fall back to upload time.
    update!(captured_at: captured_at || blob.metadata["captured_at"] || created_at)
  end

  # STI: Photo/Video share the moment-level authorization rules.
  def policy_class
    MomentPolicy
  end

  # The uploader's color, derived from its position among the album's users.
  def uploader_color
    @uploader_color ||= Components::Palette.new.hex(album.users.index { |user| user.id == uploader_id })
  end

  private

  def file_present
    errors.add(:file, :blank) unless file.attached?
  end
end
