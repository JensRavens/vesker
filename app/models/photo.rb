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
class Photo < Moment
  # Declared per STI subclass: the gem keeps callbacks in a per-class registry, and
  # attachments load as Photo/Video, not the base Moment (shared body lives in Moment).
  after_analyze_attached(:file) { |_attachment, blob| after_file_analyzed(blob) }
end
