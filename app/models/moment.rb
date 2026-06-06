# == Schema Information
#
# Table name: moments
#
#  id             :string           not null, primary key
#  captured_at    :datetime         not null
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
  belongs_to :uploader, class_name: "Ownership", counter_cache: :moments_count, inverse_of: :moments

  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :file

  validate :file_present, on: :create

  scope :chronologic, -> { order(:captured_at, :id) }

  # The uploader's color, derived from its position among the album's users.
  def uploader_color
    @uploader_color ||= Components::Palette.new.hex(album.users.index { |user| user.id == uploader.user_id })
  end

  private

  def file_present
    errors.add(:file, :blank) unless file.attached?
  end
end
