require "application_system_test_case"

class AlbumMenuTest < ApplicationSystemTestCase
  describe "the album overflow menu" do
    it "lets anyone share via a QR modal but hides 'Everything except mine' from anonymous visitors" do
      album = albums.lisbon

      visit album_path(album)

      # Logged out: only "Download everything" (plus Share) — no "except mine".
      find("button.hero__menu").click
      within ".popover" do
        expect(page).to have_text("Download everything")
        expect(page).to have_no_text("Everything except mine")
        click_button "Share this album"
      end

      # Share opens the QR modal with the link and a real <svg> QR.
      within ".modal__frame" do
        expect(page).to have_css("svg")
        expect(page).to have_text(album.slug)
        expect(page).to have_button("Copy")
      end
    end

    it "shows 'Everything except mine' to a logged-in visitor" do
      album = albums.lisbon

      login users.nomad
      visit album_path(album)

      find("button.hero__menu").click
      within ".popover" do
        expect(page).to have_text("Everything except mine")
      end
    end
  end
end
