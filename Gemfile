source "https://rubygems.org"

# Core
gem "rails", "~> 8.1.3"
gem "puma", ">= 5.0"

# Database
gem "sqlite3", ">= 2.1"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Extensions
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "image_processing", "~> 1.2"
gem "shimmer"
gem "phlex-rails"
gem "literal"
gem "pundit"
gem "positioning"
gem "exifr"
gem "activestorage-after_analyze_attached"
gem "rqrcode"
gem "zip_kit"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: [:windows, :jruby]

# Assets
gem "propshaft"
gem "vite_rails"

# Deployment
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: [:mri, :windows], require: "debug/prelude"
  gem "dotenv-rails"
  gem "oaken"
end

group :development do
  gem "web-console"
  gem "annotaterb", require: false
end

group :test do
  gem "capybara"
  gem "capybara-playwright-driver"
  gem "rspec-expectations"
  gem "standard", require: false
  gem "rubocop-rails", require: false
  gem "brakeman", require: false
  gem "bundler-audit", require: false
end
