require "application_system_test_case"

class AlbumMenuTest < ApplicationSystemTestCase
  describe "the album overflow menu" do
    it "gates 'Everything except mine' on login and shares via a QR modal" do
      album = albums.lisbon

      visit album_path(album)

      # Logged out: only "Download everything" (plus Share) — no "except mine".
      find("button.hero__menu").click
      within ".popover" do
        expect(page).to have_text("Download everything")
        expect(page).to have_no_text("Everything except mine")
      end

      # Share opens the QR modal with the link and a real <svg> QR.
      within ".popover" do
        click_button "Share this album"
      end
      within ".modal__frame" do
        expect(page).to have_css("svg")
        expect(page).to have_text(album.slug)
        expect(page).to have_button("Copy")
      end

      # Log in via the like flow, then the menu gains "Everything except mine".
      visit album_path(album)
      moment = album.moments.chronologic.first
      visit album_moment_path(album, moment)
      find("button[aria-label='Like']").click
      within ".modal__frame" do
        fill_in "email", with: "nomad@example.com"
        click_button "Continue"
      end
      run_jobs
      code = last_mail!.text[/\b\d{6}\b/]
      within ".modal__frame" do
        fill_in "code", with: code
        click_button "Confirm"
        click_button "Not now"
      end
      expect(page).to have_no_css(".modal--open")

      visit album_path(album)
      find("button.hero__menu").click
      within ".popover" do
        expect(page).to have_text("Everything except mine")
      end
    end
  end
end
