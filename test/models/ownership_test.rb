require "test_helper"

class OwnershipTest < ActiveSupport::TestCase
  describe "single creator" do
    it "rejects a second creator on the same album" do
      second_creator = Ownership.new(album: albums.lisbon, user: users.nomad, role: :creator)
      expect(second_creator).not_to be_valid
      expect(second_creator.errors[:role]).to include("album already has a creator")
    end
  end
end
