require "application_system_test_case"

class UploadTest < ApplicationSystemTestCase
  describe "uploading photos" do
    it "prompts anonymous visitors to log in" do
      visit album_path(albums.lisbon)
      click_button "Add photos"

      within ".modal__frame" do
        expect(page).to have_text("Add your name to the album")
      end
    end

    it "lets a logged-in visitor direct-upload a file into the album" do
      album = albums.lisbon
      initial = album.moments.count

      login users.nomad
      visit album_path(album)

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
