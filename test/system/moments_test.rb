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

  describe "deleting a moment" do
    it "hides the trashcan from anonymous visitors" do
      visit album_moment_path(albums.lisbon, photos.rooftop)

      expect(page).to have_no_css("button[aria-label='Delete']")
    end

    it "lets the uploader delete it via the confirm modal, returning to the grid" do
      album = albums.lisbon
      moment = photos.rooftop # uploaded by Priya

      login users.priya
      visit album_moment_path(album, moment)

      # The trashcan shows; opening it asks to confirm before deleting.
      find("button[aria-label='Delete']").click
      within ".modal__frame" do
        expect(page).to have_text("Delete this item?")
        click_button "Delete"
      end

      # Back on the grid, the moment is gone.
      expect(page).to have_current_path(album_path(album))
      expect(page).to have_no_css("a[href='#{album_moment_path(album, moment)}']")
      expect(Moment.exists?(moment.id)).to eq(false)
    end
  end
end
