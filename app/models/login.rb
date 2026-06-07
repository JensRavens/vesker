# A passwordless login, modelled as a PORO over the request's cookie jar. It owns the
# whole flow: finding/creating the user, minting + emailing the one-time code, the
# encrypted pending/session cookies, verification, and resolving the current user.
# Nothing is persisted — the only state is in cookies.
class Login
  CODE_LENGTH = 6
  CODE_TTL = 10.minutes.freeze
  LOGIN_TTL = 30.days.freeze

  def initialize(cookies)
    @cookies = cookies
  end

  # The current signed-in user (from the :user_id cookie), memoized.
  def user
    return @user if defined?(@user)

    @user = User.find_by(id: @cookies.encrypted[:user_id])
  end

  def signed_in?
    user.present?
  end

  # Step 1: find/create the user, mint + email a code, stash the pending cookie. Returns the user.
  def start(email)
    user = find_or_create_user(email)
    code = generate_code
    UserMailer.with(user:, code:).login_code.deliver_later
    @cookies.encrypted[:pending_login] = {value: {email: user.email, code:}, expires: CODE_TTL, httponly: true}
    user
  end

  # Step 2: verify the submitted code. On success, promote to a logged-in cookie. Returns boolean.
  def verify(code)
    pending = @cookies.encrypted[:pending_login].to_h
    return false unless pending["email"].present? && code_matches?(code, pending["code"])

    @user = find_or_create_user(pending["email"])
    @cookies.delete(:pending_login)
    @cookies.encrypted[:user_id] = {value: @user.id, expires: LOGIN_TTL, httponly: true}
    true
  end

  # The address a code was sent to — straight from the cookie, no lookup.
  def pending_email
    @cookies.encrypted[:pending_login].to_h["email"]
  end

  def sign_out
    @cookies.delete(:user_id)
  end

  private

  # Email-only identity: find or create the user (race-safe).
  def find_or_create_user(email)
    normalized = email.to_s.strip.downcase
    User.find_or_create_by!(email: normalized)
  rescue ActiveRecord::RecordNotUnique
    User.find_by!(email: normalized)
  end

  def generate_code
    Config.login_code.presence ||
      SecureRandom.random_number(10**CODE_LENGTH).to_s.rjust(CODE_LENGTH, "0")
  end

  def code_matches?(submitted, expected)
    expected.present? && ActiveSupport::SecurityUtils.secure_compare(submitted.to_s, expected.to_s)
  end
end
