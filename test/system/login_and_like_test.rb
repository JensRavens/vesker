require "application_system_test_case"

class LoginAndLikeTest < ApplicationSystemTestCase
  describe "liking a moment" do
    it "logs in from the like button via the modal, then toggles a like" do
      album = albums.lisbon
      moment = album.moments.chronologic.first

      visit album_moment_path(album, moment)

      # Logged out: the heart opens the login modal.
      find("button[aria-label='Like']").click
      within ".modal__frame" do
        expect(page).to have_text("Add your name to the album")
        fill_in "email", with: "nomad@example.com"
        click_button "Continue"
        expect(page).to have_text("Check your email")
      end

      # Pull the one-time code out of the delivered email.
      run_jobs
      code = last_mail!.text[/\b\d{6}\b/]
      expect(code).not_to be_nil

      within ".modal__frame" do
        fill_in "code", with: code
        click_button "Confirm"
        # Signed in: the modal now offers to create a passkey; decline it.
        expect(page).to have_text("Add a passkey")
        click_button "Not now"
      end

      # Modal closed, page morphed into the logged-in version (no more modal trigger).
      expect(page).to have_no_css(".modal--open")
      expect(page).to have_css("form[action$='/like']")

      # Now toggle a like.
      within "form[action$='/like']" do
        find("button").click
      end
      expect(page).to have_css(".moment-detail__like--on")
    end
  end
end
