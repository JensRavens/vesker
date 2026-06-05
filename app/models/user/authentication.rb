module User::Authentication
  extend ActiveSupport::Concern

  CODE_LENGTH = 6

  class_methods do
    # Email-only identification (mirrors the prototype's `identify`): find the user
    # or create them. No password.
    def for_login(email)
      normalized = email.to_s.strip.downcase
      find_or_create_by!(email: normalized)
    rescue ActiveRecord::RecordNotUnique
      find_by!(email: normalized)
    end
  end

  # A one-time numeric code. The controller stashes it (and decides its expiry) in the
  # session; the code itself is never persisted.
  def generate_login_code
    SecureRandom.random_number(10**CODE_LENGTH).to_s.rjust(CODE_LENGTH, "0")
  end

  def deliver_login_code(code)
    UserMailer.with(user: self, code:).login_code.deliver_later
  end

  # Constant-time comparison against the code held in the session.
  def verify_login_code(submitted, expected:)
    expected.present? && ActiveSupport::SecurityUtils.secure_compare(submitted.to_s, expected.to_s)
  end
end
