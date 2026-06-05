require "test_helper"

class CaptureTimeAnalyzerTest < ActiveSupport::TestCase
  describe "#metadata" do
    it "reads the EXIF capture time and dimensions from a JPEG" do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: file_fixture("exif_sample.jpg").open,
        filename: "exif_sample.jpg",
        content_type: "image/jpeg"
      )

      metadata = CaptureTimeAnalyzer.new(blob).metadata
      expect(metadata[:captured_at]).to eq("2004-09-09T15:14:26+01:00")
    end
  end
end
