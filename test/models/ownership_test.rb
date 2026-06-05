require "test_helper"

class OwnershipTest < ActiveSupport::TestCase
  describe "#color" do
    it "is 0 (ember) for the creator and increments for everyone else" do
      expect(ownerships.priya.color).to eq(0)
      expect(albums.lisbon.ownerships.order(:color).pluck(:color)).to eq([0, 1, 2, 3, 4, 5])
    end
  end

  describe "single creator" do
    it "rejects a second creator on the same album" do
      second_creator = Ownership.new(album: albums.lisbon, user: users.nomad, role: :creator)
      expect(second_creator).not_to be_valid
      expect(second_creator.errors[:role]).to include("album already has a creator")
    end
  end
end
