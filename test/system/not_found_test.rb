require "application_system_test_case"

class NotFoundTest < ApplicationSystemTestCase
  describe "missing records" do
    it "shows the invalid-link page for an unknown album" do
      visit "/albums/does-not-exist"

      expect(page).to have_content("This album link")
      expect(page).to have_content("may no longer exist")
    end

    it "shows the invalid-link page for a missing moment in a real album" do
      visit "/albums/#{albums.lisbon.slug}/moments/missing"

      expect(page).to have_content("This album link")
    end
  end
end
