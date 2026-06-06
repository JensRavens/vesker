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
end
