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
class Video < Moment
  # Declared per STI subclass (see Photo): the gem's callback registry isn't inherited.
  after_analyze_attached(:file) do |_attachment, blob|
    captured_at = blob.metadata["captured_at"]
    update_column(:captured_at, captured_at) if captured_at.present?
  end

  # Seconds, from Active Storage's video analysis (requires ffmpeg).
  def duration
    file.blob&.metadata&.dig("duration")
  end
end
