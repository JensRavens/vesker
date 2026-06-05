require "test_helper"

class MomentTest < ActiveSupport::TestCase
  describe "validations" do
    it "requires an attached file" do
      expect(Photo.new(album: albums.lisbon, uploader: ownerships.priya)).not_to be_valid
    end
  end

  describe "#captured_at" do
    it "is assigned from EXIF once the file is analyzed" do
      photo = Photo.new(album: albums.lisbon, uploader: ownerships.priya)
      photo.file.attach(io: file_fixture("exif_sample.jpg").open, filename: "exif_sample.jpg", content_type: "image/jpeg")
      photo.save!
      photo.file.blob.analyze # what Active Storage's AnalyzeJob does; fires after_analyze_attached

      expect(photo.reload.captured_at).to eq("2004-09-09T15:14:26+01:00".to_time)
    end
  end

  describe ".chronologic" do
    it "orders by capture time" do
      upload_photo
      captured_ats = albums.lisbon.moments.chronologic.map(&:captured_at)
      expect(captured_ats).to eq(captured_ats.sort)
    end
  end

  def upload_photo
    Photo.new(album: albums.lisbon, uploader: ownerships.priya).tap do |photo|
      photo.file.attach(io: StringIO.new("img"), filename: "p.png", content_type: "image/png")
      photo.save!
    end
  end
end
