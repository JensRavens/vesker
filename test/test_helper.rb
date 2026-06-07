ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Minitest specs (describe/it) with RSpec matchers (expect), keeping Minitest's speed.
require "minitest/spec"
require "rspec/expectations/minitest_integration"

require_relative "support/mail_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Write tests as Minitest specs: `describe`/`it` on top of ActiveSupport::TestCase
    # (so each example still gets DB transactions + the Oaken dataset).
    extend Minitest::Spec::DSL

    # Seed the shared Oaken dataset before tests (replaces YAML fixtures).
    include Oaken.loader.test_setup

    # Friendly email assertions (last_mail/run_jobs) + a clean deliveries box per test.
    include MailHelper
  end
end
