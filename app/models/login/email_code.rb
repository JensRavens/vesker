# The emailed one-time code login strategy: identifies a user by email, mints + emails a
# 6-digit code, and verifies it. State is the encrypted `:pending_login` cookie (email +
# code, expiring with the code); on success it hands the user to `Login#sign_in`.
class Login
  class EmailCode
    CODE_LENGTH = 6
    CODE_TTL = 10.minutes.freeze

    def initialize(login)
      @login = login
      @cookies = login.cookies
    end

    # Step 1: find/create the user, mint + email a code, stash the pending cookie. Returns the user.
    def start(email)
      user = find_or_create_user(email)
      code = generate_code
      UserMailer.with(user:, code:).login_code.deliver_later
      @cookies.encrypted[:pending_login] = {value: {email: user.email, code:}, expires: CODE_TTL, httponly: true}
      user
    end

    # Step 2: verify the submitted code. On success, sign in. Returns boolean.
    def verify(code)
      pending = @cookies.encrypted[:pending_login].to_h
      return false unless pending["email"].present? && code_matches?(code, pending["code"])

      @cookies.delete(:pending_login)
      @login.sign_in(find_or_create_user(pending["email"]))
      true
    end

    # The address a code was sent to — straight from the cookie, no lookup.
    def pending_email
      @cookies.encrypted[:pending_login].to_h["email"]
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
end
