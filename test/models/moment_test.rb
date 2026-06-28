require "test_helper"

class MomentTest < ActiveSupport::TestCase
  describe "validations" do
    it "requires an attached file" do
      expect(Photo.new(album: albums.lisbon, uploader: users.priya)).not_to be_valid
    end
  end

  describe "#captured_at" do
    it "is assigned from EXIF once the file is analyzed" do
      photo = Photo.new(album: albums.lisbon, uploader: users.priya)
      photo.file.attach(io: file_fixture("exif_sample.jpg").open, filename: "exif_sample.jpg", content_type: "image/jpeg")
      photo.save!
      photo.file.blob.analyze # what Active Storage's AnalyzeJob does; fires after_analyze_attached

      expect(photo.reload.captured_at).to eq("2004-09-09T15:14:26+01:00".to_time)
    end
  end

  describe ".chronologic" do
    it "orders by capture time" do
      captured_ats = albums.lisbon.moments.ready.chronologic.map(&:captured_at)
      expect(captured_ats).to eq(captured_ats.sort)
    end
  end

  describe ".with_checksum" do
    it "finds an album moment by its attached file's checksum" do
      moment = upload_photo

      expect(albums.lisbon.moments.with_checksum(moment.file.checksum)).to include(moment)
    end

    it "is empty for an unknown checksum" do
      expect(Moment.with_checksum("nope")).to be_empty
    end
  end

  describe ".ready / .pending" do
    it "partitions moments by whether processing has finished" do
      moment = upload_photo # not analyzed yet -> captured_at nil

      expect(albums.lisbon.moments.pending).to include(moment)
      expect(albums.lisbon.moments.ready).not_to include(moment)
    end
  end

  describe "once the file is analyzed" do
    it "warms the grid representation and reveals the moment by setting captured_at" do
      photo = upload_real_photo

      expect { photo.file.blob.analyze }.to change { photo.reload.captured_at }.from(nil)
      # The grid representation is now materialized, so a later request never generates it.
      expect(photo.file.blob.variant_records).to be_present
    end

    it "still reveals the moment when warming the representation fails (not hidden forever)" do
      photo = upload_photo # a fake, undecodable image — warming will raise

      expect { photo.file.blob.analyze }.to raise_error(Vips::Error) # loud, not swallowed
      expect(albums.lisbon.moments.ready).to include(photo.reload) # but still visible (upload-time captured_at)
    end
  end

  def upload_photo
    Photo.new(album: albums.lisbon, uploader: users.priya).tap do |photo|
      photo.file.attach(io: StringIO.new("img"), filename: "p.png", content_type: "image/png")
      photo.save!
    end
  end

  def upload_real_photo
    Photo.new(album: albums.lisbon, uploader: users.priya).tap do |photo|
      photo.file.attach(io: file_fixture("exif_sample.jpg").open, filename: "exif_sample.jpg", content_type: "image/jpeg")
      photo.save!
    end
  end
end
