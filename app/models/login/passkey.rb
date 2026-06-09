# The WebAuthn passkey login strategy: mints the credential options, verifies an
# assertion (discoverable login → resolves the user from the credential) or an attestation
# (registering a passkey for the signed-in user). The WebAuthn details live on the
# `::Passkey` model; this class only bridges them to the challenge cookie + `Login#sign_in`.
# `::Passkey` (the model) is referenced with a leading `::` so it isn't shadowed by this class.
class Login
  class Passkey
    CHALLENGE_TTL = 5.minutes.freeze

    def initialize(login)
      @login = login
      @cookies = login.cookies
    end

    # Mint discoverable-login options and stash the challenge for the verify step.
    def authentication_options
      stash_challenge(::Passkey.authentication_options)
    end

    # Verify a passkey assertion and sign in. The user is resolved purely from which
    # credential answered — no email, no find-or-create. Returns boolean.
    def verify(credential)
      challenge = @cookies.encrypted[:webauthn_challenge]
      return false if challenge.blank?

      passkey = ::Passkey.verify_authentication(credential, challenge)
      return false unless passkey

      @cookies.delete(:webauthn_challenge)
      @login.sign_in(passkey.user)
      true
    rescue WebAuthn::Error
      false
    end

    # Mint registration options for the signed-in user and stash the challenge.
    def registration_options
      return unless @login.user

      stash_challenge(::Passkey.registration_options(@login.user))
    end

    # Verify an attestation and persist a passkey for the signed-in user. Returns boolean.
    def register(credential, nickname: nil)
      return false unless @login.user

      challenge = @cookies.encrypted[:webauthn_challenge]
      return false if challenge.blank?

      ::Passkey.register(@login.user, credential, challenge, nickname:)
      @cookies.delete(:webauthn_challenge)
      true
    rescue WebAuthn::Error, ActiveRecord::RecordInvalid
      false
    end

    private

    # Persist the challenge in a short-lived cookie and return the options to render.
    def stash_challenge(options)
      @cookies.encrypted[:webauthn_challenge] = {value: options.challenge, expires: CHALLENGE_TTL, httponly: true, secure: Rails.env.production?, same_site: :lax}
      options
    end
  end
end
