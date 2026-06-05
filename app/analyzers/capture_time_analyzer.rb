require "exifr/jpeg"

# Active Storage analyzer that adds a photo's original capture time (from JPEG EXIF, read
# in pure Ruby) on upload. Prepended so it wins for JPEGs; it delegates to the analyzer
# Active Storage would otherwise have used and merges that metadata (dimensions, etc.).
class CaptureTimeAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    blob.content_type.to_s.start_with?("image/jpeg")
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
    download_blob_to_tempfile do |file|
      EXIFR::JPEG.new(file.path).date_time_original&.iso8601
    end
  rescue
    nil
  end
end
