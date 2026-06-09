require "application_system_test_case"

class PasskeyTest < ApplicationSystemTestCase
  describe "creating a passkey after logging in" do
    it "offers a passkey on login and registers one against a virtual authenticator" do
      # The WebAuthn config is built from default_url_options (example.com), but the test
      # server runs on a dynamic localhost port — point both Capybara and the relying party
      # at that real origin so the browser's assertion verifies (and localhost is a valid
      # rp_id, unlike a raw 127.0.0.1).
      origin = "http://localhost:#{Capybara.current_session.server.port}"
      original_host = Capybara.app_host
      original_origins = WebAuthn.configuration.allowed_origins
      original_rp_id = WebAuthn.configuration.rp_id
      Capybara.app_host = origin
      WebAuthn.configuration.allowed_origins = [origin]
      WebAuthn.configuration.rp_id = "localhost"
      add_virtual_authenticator

      album = albums.lisbon
      moment = album.moments.chronologic.first
      visit album_moment_path(album, moment)

      find("button[aria-label='Like']").click
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
        expect(page).to have_text("Add a passkey")
        click_button "Create a passkey"
      end

      # Registration done: the modal closed (server `ui.navigate_to`) and a passkey is
      # now stored for the user.
      expect(page).to have_no_css(".modal--open")
      expect(User.find_by(email: "nomad@example.com").passkeys.count).to eq(1)
    ensure
      Capybara.app_host = original_host
      WebAuthn.configuration.allowed_origins = original_origins
      WebAuthn.configuration.rp_id = original_rp_id
    end
  end

  private

  # Register a CTAP2 platform authenticator that auto-approves user verification, so
  # navigator.credentials.create resolves without a real device.
  def add_virtual_authenticator
    page.driver.with_playwright_page do |pw_page|
      cdp = pw_page.context.new_cdp_session(pw_page)
      cdp.send_message("WebAuthn.enable")
      cdp.send_message("WebAuthn.addVirtualAuthenticator", params: {
        options: {
          protocol: "ctap2",
          transport: "internal",
          hasResidentKey: true,
          hasUserVerification: true,
          isUserVerified: true,
          automaticPresenceSimulation: true
        }
      })
    end
  end
end
