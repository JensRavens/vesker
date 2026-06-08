require "test_helper"

class AlbumPolicyTest < ActiveSupport::TestCase
  describe "#create?" do
    it "is allowed only for site admins" do
      expect(AlbumPolicy.new(users.marco, Album).create?).to eq(true)  # admin
      expect(AlbumPolicy.new(users.priya, Album).create?).to eq(false) # an album creator, but not a site admin
      expect(AlbumPolicy.new(nil, Album).create?).to eq(false)         # guest
    end
  end

  describe "#update?" do
    it "is allowed for the album's creator or any admin" do
      album = albums.lisbon

      expect(AlbumPolicy.new(users.priya, album).update?).to eq(true)  # creator
      expect(AlbumPolicy.new(users.marco, album).update?).to eq(true)  # admin
      expect(AlbumPolicy.new(users.lena, album).update?).to eq(false)  # plain contributor
      expect(AlbumPolicy.new(nil, album).update?).to eq(false)         # guest
    end
  end
end
