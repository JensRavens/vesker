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
class Video < Moment
  # Declared per STI subclass (see Photo): the gem's callback registry isn't inherited.
  after_analyze_attached(:file) { |_attachment, blob| after_file_analyzed(blob) }

  # Seconds, from Active Storage's video analysis (requires ffmpeg).
  def duration
    file.blob&.metadata&.dig("duration")
  end
end
