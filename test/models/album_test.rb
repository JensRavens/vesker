require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  describe "#users" do
    it "lists the album's uploaders ordered by first upload, excluding non-uploaders" do
      participants = albums.lisbon.users

      expect(participants.first).to eq(users.priya) # uploaded the very first moment
      expect(participants).not_to include(users.nomad) # never uploaded
    end
  end
end
