# == Schema Information
#
# Table name: passkeys
#
#  id          :string           not null, primary key
#  nickname    :string
#  public_key  :string           not null
#  sign_count  :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :string           not null
#  user_id     :string           not null
#
class Passkey < ApplicationRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true

  class << self
    # Options for a discoverable (usernameless) login: no `allow:` list, so any registered
    # passkey can answer. The caller stashes `options.challenge` for the verify step.
    def authentication_options
      WebAuthn::Credential.options_for_get(user_verification: "preferred")
    end

    # Registration options for `user`. `resident_key: "required"` makes the credential
    # discoverable (what enables the usernameless login above); `exclude` blocks re-enrolling
    # an authenticator the user already has.
    def registration_options(user)
      WebAuthn::Credential.options_for_create(
        user: {id: user.id, name: user.email, display_name: user.name},
        exclude: user.passkeys.pluck(:external_id),
        authenticator_selection: {resident_key: "required", user_verification: "preferred"}
      )
    end

    # Verify an assertion against the stored credential it names, bumping the sign count.
    # Returns the matching passkey, nil if none matches, or raises WebAuthn::Error if the
    # assertion is invalid.
    def verify_authentication(credential, challenge)
      webauthn_credential = WebAuthn::Credential.from_get(credential)
      passkey = find_by(external_id: webauthn_credential.id)
      return unless passkey

      webauthn_credential.verify(challenge, public_key: passkey.public_key, sign_count: passkey.sign_count)
      passkey.update!(sign_count: webauthn_credential.sign_count)
      passkey
    end

    # Verify an attestation and persist it as a passkey for `user`. Raises WebAuthn::Error
    # (invalid attestation) or ActiveRecord::RecordInvalid (e.g. duplicate credential).
    def register(user, credential, challenge, nickname: nil)
      webauthn_credential = WebAuthn::Credential.from_create(credential)
      webauthn_credential.verify(challenge)
      user.passkeys.create!(
        external_id: webauthn_credential.id,
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count,
        nickname: nickname.presence
      )
    end
  end
end
