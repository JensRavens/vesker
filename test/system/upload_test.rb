require "application_system_test_case"

class UploadTest < ApplicationSystemTestCase
  EXIF_SAMPLE = Rails.root.join("test/fixtures/files/exif_sample.jpg").to_s.freeze

  describe "uploading photos" do
    it "prompts anonymous visitors to log in" do
      visit album_path(albums.lisbon)
      click_button "Add photos"

      within ".modal__frame" do
        expect(page).to have_text("Add your name to the album")
      end
    end

    it "adds a dropped file to the album immediately, with no confirm step" do
      album = albums.lisbon
      initial = album.moments.count

      login users.nomad
      visit album_path(album)

      click_button "Add photos"
      within ".upload-sidebar" do
        attach_file "upload-files", EXIF_SAMPLE, make_visible: true
        expect(page).to have_text("Added") # the moment was created without clicking anything
      end
      expect(album.moments.count).to eq(initial + 1)

      # Once background processing finishes the moment becomes ready and appears (a broadcast
      # morphs it in live; here we drain the jobs and revisit, since cable is a no-op in tests).
      run_jobs
      visit album_path(album)
      expect(page).to have_css(".moment-tile", count: initial + 1)
    end

    it "refuses a file the same person already added, without creating a duplicate" do
      album = albums.lisbon
      initial = album.moments.count

      login users.nomad
      visit album_path(album)

      click_button "Add photos"
      within ".upload-sidebar" do
        attach_file "upload-files", EXIF_SAMPLE, make_visible: true
        expect(page).to have_text("Added")

        attach_file "upload-files", EXIF_SAMPLE, make_visible: true
        expect(page).to have_text("You already added this")
      end

      expect(album.moments.count).to eq(initial + 1)
    end

    it "keeps the modal open across a live page refresh" do
      login users.nomad
      visit album_path(albums.lisbon)

      click_button "Add photos"
      expect(page).to have_css(".modal--open .upload-sidebar")

      # The broadcast that fires when someone's upload lands morphs the page underneath; the modal
      # must survive it rather than close mid-upload. Inject the same refresh stream and wait for the
      # morph to finish before asserting. We assert on `.modal--open` because Shimmer drops that class
      # *synchronously* when something closes the modal — so this fails fast on a regression where
      # either the morph removes the modal or the turbo:before-visit handler closes it.
      page.evaluate_async_script(<<~JS)
        const done = arguments[0];
        document.addEventListener("turbo:render", () => done(), { once: true });
        document.body.insertAdjacentHTML("beforeend", '<turbo-stream action="refresh"></turbo-stream>');
      JS

      expect(page).to have_css(".modal--open .upload-sidebar") # survived the morph, still open
    end

    it "tells you who already added a file when it was someone else" do
      album = albums.lisbon
      album.moments.create!(type: "Photo", uploader: users.priya,
        file: {io: File.open(EXIF_SAMPLE), filename: "exif_sample.jpg", content_type: "image/jpeg"})
      initial = album.moments.count

      login users.nomad
      visit album_path(album)

      click_button "Add photos"
      within ".upload-sidebar" do
        attach_file "upload-files", EXIF_SAMPLE, make_visible: true
        expect(page).to have_text("Already added by Priya")
      end

      expect(album.moments.count).to eq(initial)
    end
  end
end
