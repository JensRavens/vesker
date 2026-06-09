class SessionsController < ApplicationController
  include Shimmer::RemoteNavigation

  # Basic brute-force / abuse protection: cap code requests (per IP and per email, to curb
  # email-bombing a single address from many IPs) and cap code guesses per IP.
  rate_limit to: 5, within: 3.minutes, only: :create, name: "session-create-ip"
  rate_limit to: 5, within: 3.minutes, only: :create, name: "session-create-email",
    by: -> { params[:email].to_s.strip.downcase.presence || request.remote_ip }
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
        ui.navigate_to(safe_referer)
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

  private

  # The credential JSON the passkey Stimulus controller posts in a hidden field.
  def credential_param
    JSON.parse(params.require(:credential))
  rescue JSON::ParserError
    {}
  end
end
