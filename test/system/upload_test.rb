require "application_system_test_case"

class UploadTest < ApplicationSystemTestCase
  describe "uploading photos" do
    it "logs in from Add photos, direct-uploads a file, then adds it to the album" do
      album = albums.lisbon
      initial = album.moments.count

      visit album_path(album)

      # Logged out: Add photos opens the login modal.
      click_button "Add photos"
      within ".modal__frame" do
        expect(page).to have_text("Add your name to the album")
        fill_in "email", with: "nomad@example.com"
        click_button "Continue"
        expect(page).to have_text("Check your email")
      end

      run_jobs
      code = last_mail!.text[/\b\d{6}\b/]
      within ".modal__frame" do
        fill_in "code", with: code
        click_button "Confirm"
      end
      expect(page).to have_no_css(".modal--open")

      # Logged in: Add photos now opens the upload sidebar. Wait for the post-login
      # morph to settle (the trigger now carries the sidebar size) before clicking,
      # so the in-flight Turbo visit can't swap the body out from under the modal.
      expect(page).to have_css("button[data-modal-size-value='sidebar']")
      click_button "Add photos"
      within ".upload-sidebar" do
        attach_file "upload-files", Rails.root.join("test/fixtures/files/exif_sample.jpg").to_s, make_visible: true
        expect(page).to have_text("Done")
        click_button "Add 1 to album"
      end

      # Modal closed, timeline refreshed with the new moment.
      expect(page).to have_no_css(".modal--open")
      expect(page).to have_css(".moment-tile", count: initial + 1)
    end
  end
end
