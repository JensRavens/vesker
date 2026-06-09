# Fakes a passwordless login in system tests by planting the same encrypted `:user_id`
# cookie that `Login#verify` would set — so specs that aren't *about* logging in can skip
# the email-code dance and just `login(user)`.
module SessionTestHelper
  extend ActiveSupport::Concern

  # Sign `user` in for the rest of the test. Sets the cookie directly on the browser
  # context, so it's in place for the next `visit` (no page load required first).
  def login(user)
    value = Rack::Utils.escape(encrypted_user_id_cookie(user))
    page.driver.with_playwright_page do |pw_page|
      pw_page.context.add_cookies([{name: "user_id", value:, url: Capybara.current_session.server.base_url}])
    end
  end

  # Sign out by clearing the browser's cookies (drops the `:user_id` cookie). Takes effect
  # on the next `visit`.
  def logout
    page.driver.with_playwright_page { |pw_page| pw_page.context.clear_cookies }
  end

  private

  # The wire value Rails would write for `cookies.encrypted[:user_id] = user.id`,
  # built through a throwaway cookie jar keyed off the app's secret/salts.
  def encrypted_user_id_cookie(user)
    jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
    jar.encrypted[:user_id] = user.id
    jar.instance_variable_get(:@set_cookies).fetch("user_id").fetch(:value)
  end
end
