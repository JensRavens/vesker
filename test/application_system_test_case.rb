require "test_helper"
require "capybara-playwright-driver"

# Drive system tests with a real Chromium via Playwright (mirrors the
# nerdgeschoss setup). The browser binary is installed with
# `npx playwright install chromium`.
Capybara.register_driver(:vesker_playwright) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium, headless: true)
end

Capybara.default_driver = Capybara.javascript_driver = :vesker_playwright
Capybara.enable_aria_label = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :vesker_playwright
end
