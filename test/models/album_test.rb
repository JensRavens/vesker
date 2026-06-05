require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  describe "#creator" do
    it "resolves through the ownership with the creator role" do
      expect(albums.lisbon.creator).to eq(users.priya)
    end
  end
end
