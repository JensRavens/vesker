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

    it "reads the creation time from a video's container metadata" do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join("db/seeds/files/videos/movie-short.mp4").open,
        filename: "movie-short.mp4",
        content_type: "video/mp4"
      )

      metadata = CaptureTimeAnalyzer.new(blob).metadata
      expect(metadata[:captured_at]).to eq("2019-12-10T11:20:32Z")
    end
  end
end
