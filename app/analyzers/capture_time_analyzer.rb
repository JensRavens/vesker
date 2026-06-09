require "json"
require "time"
require "vips"

# Active Storage analyzer that records a moment's original capture time on upload.
#
# - Images (JPEG, HEIC, …): EXIF DateTimeOriginal + OffsetTimeOriginal, read via libvips
#   (exifr only handles JPEG, so HEIC fell through to the upload time).
# - Videos: the container creation date via ffprobe. For Apple clips `creation_time` is the
#   re-write/upload time, so we prefer `com.apple.quicktime.creationdate` (the real shot time).
#
# Prepended so it wins for any image/video; it delegates to the analyzer Active Storage would
# otherwise have used and merges that metadata (dimensions, duration, …).
class CaptureTimeAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    blob.image? || blob.video?
  end

  def metadata
    delegated_metadata.merge(captured_at:).compact
  end

  private

  def delegated_metadata
    original = ActiveStorage.analyzers.find { |analyzer| analyzer != self.class && analyzer.accept?(blob) }
    original ? original.new(blob).metadata : {}
  end

  def captured_at
    blob.video? ? video_captured_at : image_captured_at
  rescue => e
    # A file with no readable capture time keeps the CURRENT_TIMESTAMP default — never fail an upload.
    logger.warn { "CaptureTimeAnalyzer could not read capture time for blob #{blob.id}: #{e.class}: #{e.message}" }
    nil
  end

  def image_captured_at
    download_blob_to_tempfile do |file|
      image = Vips::Image.new_from_file(file.path)
      stamp = exif(image, "exif-ifd2-DateTimeOriginal") || exif(image, "exif-ifd0-DateTime")
      offset = exif(image, "exif-ifd2-OffsetTimeOriginal") || exif(image, "exif-ifd2-OffsetTime")
      to_iso8601(stamp, offset)
    end
  end

  def video_captured_at
    tags = ffprobe_format_tags
    stamp = tags["com.apple.quicktime.creationdate"].presence || tags["creation_time"].presence
    stamp && Time.parse(stamp).iso8601
  end

  # The libvips EXIF getter returns "<value> (<value>, <type>, …)"; keep just the value.
  def exif(image, field)
    image.get(field).to_s.split(" (").first.presence
  rescue Vips::Error
    nil
  end

  # EXIF stamps look like "2004:09:09 15:14:26"; only the date half uses colons.
  def to_iso8601(stamp, offset)
    return nil if stamp.blank?
    naive = stamp.sub(":", "-").sub(":", "-")
    Time.parse(offset ? "#{naive} #{offset}" : naive).iso8601
  end

  def ffprobe_format_tags
    download_blob_to_tempfile do |file|
      output = IO.popen(["ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", file.path], &:read)
      JSON.parse(output).dig("format", "tags") || {}
    end
  end
end
