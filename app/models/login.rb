# The login session, modelled as a PORO over the request's cookie jar. It owns the
# logged-in `:user_id` cookie (resolving / setting / clearing the current user) and
# composes the two ways to *become* logged in: an emailed one-time code (`#email_code`)
# and a WebAuthn passkey (`#passkey`). Each strategy verifies a user and calls back to
# `#sign_in`. Nothing is persisted beyond the encrypted cookies.
class Login
  LOGIN_TTL = 30.days.freeze

  def initialize(cookies)
    @cookies = cookies
  end

  # The cookie jar, shared with the strategies (they stash their own pending/challenge cookies).
  attr_reader :cookies

  # The current signed-in user (from the :user_id cookie), memoized.
  def user
    return @user if defined?(@user)

    @user = User.find_by(id: @cookies.encrypted[:user_id])
  end

  def signed_in?
    user.present?
  end

  def sign_out
    @cookies.delete(:user_id)
  end

  # Promote a verified user to the logged-in cookie — the shared finish line both
  # strategies cross. Memoizes so the rest of the request sees the user immediately.
  def sign_in(user)
    @user = user
    @cookies.encrypted[:user_id] = {value: user.id, expires: LOGIN_TTL, httponly: true, secure: Rails.env.production?, same_site: :lax}
    user
  end

  # Emailed one-time code flow.
  def email_code
    @email_code ||= EmailCode.new(self)
  end

  # WebAuthn passkey flow.
  def passkey
    @passkey ||= Passkey.new(self)
  end
end
