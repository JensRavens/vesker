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

  describe "browsing between moments" do
    it "steps to the next moment, hiding the back arrow at the start" do
      album = albums.lisbon
      first, second = album.moments.chronologic.first(2)

      visit album_moment_path(album, first)
      expect(page).to have_no_link("Previous moment")

      click_link "Next moment"

      expect(page).to have_current_path(album_moment_path(album, second))
      expect(page).to have_link("Previous moment")
    end

    it "skips a moment that is still processing" do
      album = albums.lisbon
      first, second, third = album.moments.chronologic.first(3)
      second.update_column(:captured_at, nil) # mid-sequence, still analyzing

      visit album_moment_path(album, first)
      click_link "Next moment"

      expect(page).to have_current_path(album_moment_path(album, third))
    end
  end

  describe "a moment that is still processing" do
    it "404s its detail page until it is ready" do
      moment = Photo.new(album: albums.lisbon, uploader: users.priya)
      moment.file.attach(io: StringIO.new("img"), filename: "p.png", content_type: "image/png")
      moment.save! # not analyzed -> captured_at nil -> pending

      visit album_moment_path(albums.lisbon, moment)

      expect(page).to have_content("This album link")
    end
  end

  describe "deleting a moment" do
    it "hides the trashcan from anonymous visitors" do
      visit album_moment_path(albums.lisbon, photos.rooftop)

      expect(page).to have_no_css("button[aria-label='Delete']")
    end

    it "lets the uploader delete it after confirming, returning to the grid" do
      album = albums.lisbon
      moment = photos.rooftop # uploaded by Priya

      login users.priya
      visit album_moment_path(album, moment)

      # The trashcan shows; Turbo's confirm (our styled dialog) asks before deleting.
      find("button[aria-label='Delete']").click
      within "#confirm-dialog" do
        expect(page).to have_text("Delete this item?")
        click_button "Delete"
      end

      # Back on the grid, the moment is gone.
      expect(page).to have_current_path(album_path(album))
      expect(page).to have_no_css("a[href='#{album_moment_path(album, moment)}']")
      expect(Moment.exists?(moment.id)).to eq(false)
    end
  end

  describe "commenting" do
    it "shows an empty state on a moment with no comments yet" do
      visit album_moment_path(albums.lisbon, photos.tiles)

      expect(page).to have_content("No comments yet")
    end

    it "prompts anonymous visitors to log in when they try to comment" do
      visit album_moment_path(albums.lisbon, photos.rooftop)

      fill_in "comment[body]", with: "let me in"
      click_button "Post comment"

      within ".modal__frame" do
        expect(page).to have_text("Add your name to the album")
      end
    end

    it "lets a logged-in visitor post a comment that lands newest-first" do
      album = albums.lisbon
      moment = photos.tram # already has Lena's "this is SO lisbon"

      login users.nomad
      visit album_moment_path(album, moment)

      fill_in "comment[body]", with: "joining the trip"
      click_button "Post comment"

      # Newest first: the just-posted comment is the first row in the list, and the
      # body is stored verbatim (not the wrapping params hash).
      expect(find(".moment-detail__comments .comment", match: :first)).to have_text("joining the trip")
      expect(moment.comments.order(created_at: :desc).first.body).to eq("joining the trip")
    end
  end
end
