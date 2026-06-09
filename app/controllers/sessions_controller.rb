class SessionsController < ApplicationController
  include Shimmer::RemoteNavigation

  # Basic brute-force protection (per IP): cap code requests and code guesses.
  rate_limit to: 5, within: 3.minutes, only: :create, name: "session-create"
  rate_limit to: 10, within: 3.minutes, only: :verify, name: "session-verify"

  # Step 1: the email form (loaded into the modal). Carries the passkey auth challenge
  # so the email field can offer conditional-mediation (autofill) passkey login.
  def new
    render Views::Sessions::New.new(passkey_options: login.passkey.authentication_options.as_json),
      layout: false
  end

  # A passkey login (discoverable, posted in a hidden `credential` field) reuses this
  # endpoint; otherwise it's step 1 → 2 of the email flow.
  def create
    if params[:credential].present?
      if login.passkey.verify(credential_param)
        ui.navigate_to(request.referer)
      else
        render Views::Sessions::New.new(
          passkey_options: login.passkey.authentication_options.as_json,
          error: t(".invalid_passkey")
        ), layout: false, status: :unprocessable_entity
      end
    else
      user = login.email_code.start(params[:email])
      render Views::Sessions::Verify.new(email: user.email), layout: false
    end
  end

  # Step 2: verify the code. On success the user is signed in; offer to create a passkey
  # (with the registration challenge) instead of closing the modal.
  def verify
    if login.email_code.verify(params[:code])
      render Views::Sessions::Passkey.new(passkey_options: login.passkey.registration_options.as_json),
        layout: false
    else
      render Views::Sessions::Verify.new(email: login.email_code.pending_email, error: t(".invalid_code")),
        layout: false, status: :unprocessable_entity
    end
  end

  def destroy
    login.sign_out
    redirect_back fallback_location: "/", allow_other_host: false
  end
end
