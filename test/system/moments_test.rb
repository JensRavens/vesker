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
      visit album_moment_path(album, moment)

      log_in_as "priya@example.com"

      # The trashcan now shows; opening it asks to confirm before deleting.
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

  private

  # Logs in through the like modal on the current moment page, then waits for the
  # logged-in morph to settle. The session verify navigates back to the referer.
  def log_in_as(email)
    find("button[aria-label='Like']").click
    within ".modal__frame" do
      fill_in "email", with: email
      click_button "Continue"
    end
    run_jobs
    code = last_mail!.text[/\b\d{6}\b/]
    within ".modal__frame" do
      fill_in "code", with: code
      click_button "Confirm"
    end
    expect(page).to have_no_css(".modal--open")
  end
end
