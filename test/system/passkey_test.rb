require "application_system_test_case"

class PasskeyTest < ApplicationSystemTestCase
  describe "passkeys" do
    it "creates a passkey after an email-code login, then signs back in with it" do
      # The WebAuthn config is built from default_url_options (example.com), but the test
      # server runs on a dynamic localhost port — point both Capybara and the relying party
      # at that real origin so the browser's ceremonies verify (and localhost is a valid
      # rp_id, unlike a raw 127.0.0.1).
      origin = "http://localhost:#{Capybara.current_session.server.port}"
      original_host = Capybara.app_host
      original_origins = WebAuthn.configuration.allowed_origins
      original_rp_id = WebAuthn.configuration.rp_id
      Capybara.app_host = origin
      WebAuthn.configuration.allowed_origins = [origin]
      WebAuthn.configuration.rp_id = "localhost"

      # A CTAP2 platform authenticator that auto-approves user verification and holds
      # discoverable credentials, so navigator.credentials.* resolves without a real device.
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

      album = albums.lisbon
      moment = album.moments.chronologic.first

      # Log in with the email code, then create a passkey on the offer screen.
      visit album_moment_path(album, moment)
      find("button[aria-label='Like']").click
      within ".modal__frame" do
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

      expect(page).to have_no_css(".modal--open")
      expect(User.find_by(email: "nomad@example.com").passkeys.count).to eq(1)

      # Returning signed-out, the passkey is still on the device. Opening the login modal
      # surfaces it via the email field's conditional-mediation autofill, which signs the
      # user straight back in — no email, no code.
      logout
      visit album_moment_path(album, moment)
      expect(page).to have_no_css("form[action$='/like']") # logged out

      find("button[aria-label='Like']").click

      expect(page).to have_css("form[action$='/like']", wait: 10) # signed in again
      expect(page).to have_no_css(".modal--open")
    ensure
      Capybara.app_host = original_host
      WebAuthn.configuration.allowed_origins = original_origins
      WebAuthn.configuration.rp_id = original_rp_id
    end
  end
end
