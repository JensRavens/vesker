require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# App config reader (shimmer): `Config.foo` resolves from ENV (`.env*` in dev/test via
# dotenv-rails), then credentials. `Config.foo!` requires it; `Config.foo?` coerces a bool.
# Not frozen: shimmer's Config#stub mutates the singleton in tests.
Config = Shimmer::Config.instance # rubocop:disable Style/MutableConstant

module Vesker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ["assets", "tasks"])

    # All tables use UUID v7 primary keys (generated app-side in ApplicationRecord,
    # since SQLite has no native uuid). String-typed PKs/FKs in every migration.
    config.generators do |g|
      g.orm :active_record, primary_key_type: :string
    end

    # Style every form by default — f.text_field / f.button come out with our classes.
    config.action_view.default_form_builder = "ApplicationFormBuilder"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
