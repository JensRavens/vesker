require "test_helper"

class AlbumPolicyTest < ActiveSupport::TestCase
  describe "#create?" do
    it "is allowed only for site admins" do
      expect(AlbumPolicy.new(users.marco, Album).create?).to eq(true)  # admin
      expect(AlbumPolicy.new(users.priya, Album).create?).to eq(false) # a regular user
      expect(AlbumPolicy.new(nil, Album).create?).to eq(false)         # guest
    end
  end

  describe "#update?" do
    it "is allowed only for site admins" do
      album = albums.lisbon

      expect(AlbumPolicy.new(users.marco, album).update?).to eq(true)  # admin
      expect(AlbumPolicy.new(users.priya, album).update?).to eq(false) # a regular user (uploaded, not admin)
      expect(AlbumPolicy.new(nil, album).update?).to eq(false)         # guest
    end
  end
end
