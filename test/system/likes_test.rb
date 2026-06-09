require "application_system_test_case"

class LikesTest < ApplicationSystemTestCase
  describe "liking a moment" do
    it "prompts anonymous visitors to log in" do
      album = albums.lisbon
      moment = album.moments.chronologic.first

      visit album_moment_path(album, moment)
      find("button[aria-label='Like']").click

      within ".modal__frame" do
        expect(page).to have_text("Add your name to the album")
      end
    end

    it "lets a logged-in visitor toggle a like" do
      album = albums.lisbon
      moment = album.moments.chronologic.first

      login users.nomad
      visit album_moment_path(album, moment)

      within "form[action$='/like']" do
        find("button").click
      end

      expect(page).to have_css(".moment-detail__like--on")
    end
  end
end
