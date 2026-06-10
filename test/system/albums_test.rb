require "application_system_test_case"

class AlbumsTest < ApplicationSystemTestCase
  describe "albums#show" do
    it "renders the title, contributor summary, and a preview per moment" do
      visit album_path(albums.lisbon)

      expect(page).to have_content("Lisbon & the Algarve")
      expect(page).to have_content("6 people · 33 moments")
      expect(page).to have_css(".moment-tile", count: 33)
    end

    it "hides moments that are still processing and shows the count" do
      photos.tram.update_column(:captured_at, nil) # simulate one still analyzing

      visit album_path(albums.lisbon)

      expect(page).to have_css(".moment-tile", count: 32)
      expect(page).to have_content("1 item still being analyzed")
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

  describe "the landing page" do
    it "prompts anonymous visitors to log in before creating" do
      visit root_path

      expect(page).to have_content("Create an album")
      click_button "Create an album"
      within ".modal__frame" do
        expect(page).to have_text("Add your name to the album")
      end
    end

    it "creates an album for a logged-in admin and opens it" do
      login users.marco # Marco is a site admin
      visit root_path

      click_link "Create an album"

      # Lands on the freshly-created album, owned by the admin.
      expect(page).to have_current_path(%r{\A/albums/})
      album = Album.order(:created_at).last
      expect(page).to have_current_path(album_path(album))
      expect(album.creator).to eq(users.marco)
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

      login users.priya # Priya is the album creator
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
end
