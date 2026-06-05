require "application_system_test_case"

class MomentsTest < ApplicationSystemTestCase
  describe "moments#show" do
    it "shows the uploader, comments, and a way back" do
      visit album_moment_path(albums.lisbon, photos.rooftop)

      expect(page).to have_content(users.priya.name)
      expect(page).to have_content("frame this one")
      expect(page).to have_content("best rooftop of the trip")
      expect(page).to have_link("Back to album")
    end
  end
end
