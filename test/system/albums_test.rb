require "application_system_test_case"

class AlbumsTest < ApplicationSystemTestCase
  describe "albums#show" do
    it "renders the title, contributor summary, and a preview per moment" do
      visit album_path(albums.lisbon)

      expect(page).to have_content("Lisbon & the Algarve")
      expect(page).to have_content("6 people · 33 moments")
      expect(page).to have_css(".moment-tile", count: 33)
    end
  end
end
