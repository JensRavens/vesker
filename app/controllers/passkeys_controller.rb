class PasskeysController < ApplicationController
  include Shimmer::RemoteNavigation

  before_action :require_login

  rate_limit to: 10, within: 3.minutes, only: :create, name: "passkey-create"

  # Persist the attestation as a passkey for the signed-in user, then close the modal
  # + morph the host page (mirrors the email verify success path).
  def create
    if login.passkey.register(credential_param)
      ui.navigate_to(request.referer)
    else
      render Views::Sessions::Passkey.new(
        passkey_options: login.passkey.registration_options.as_json,
        error: t(".failed")
      ), layout: false, status: :unprocessable_entity
    end
  end

  private

  # The credential JSON the passkey Stimulus controller posts in a hidden field.
  def credential_param
    JSON.parse(params.require(:credential))
  rescue JSON::ParserError
    {}
  end
end
