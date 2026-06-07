require "application_system_test_case"

class AlbumsTest < ApplicationSystemTestCase
  describe "albums#show" do
    it "renders the title, contributor summary, and a preview per moment" do
      visit album_path(albums.lisbon)

      expect(page).to have_content("Lisbon & the Algarve")
      expect(page).to have_content("6 people · 33 moments")
      expect(page).to have_css(".moment-tile", count: 33)
    end

    it "filters the timeline by participant via the people picker popover" do
      visit album_path(albums.lisbon)

      click_button "Filter by person" # the participants trigger

      # The popover loads its body asynchronously from the server.
      expect(page).to have_content("Everyone")
      click_link users.priya.name

      # Selecting a person changes the URL and re-renders the filtered timeline.
      expect(page).to have_content("1 of 6 people")
    end
  end

  describe "renaming the album" do
    it "hides the rename action from anonymous visitors" do
      visit album_path(albums.lisbon)

      find("button.hero__menu").click
      within ".popover" do
        expect(page).to have_no_text("Change name")
      end
    end

    it "lets the creator rename the album from the overflow menu" do
      album = albums.lisbon
      visit album_moment_path(album, album.moments.chronologic.first)

      log_in_as "priya@example.com" # Priya is the album creator

      visit album_path(album)
      find("button.hero__menu").click
      within ".popover" do
        click_button "Change name"
      end
      within ".modal__frame" do
        fill_in "album[title]", with: "Summer in Portugal"
        click_button "Save"
      end

      expect(page).to have_no_css(".modal--open")
      expect(page).to have_content("Summer in Portugal")
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
