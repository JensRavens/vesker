require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = {"cache-control" => "public, max-age=#{1.year.to_i}"}

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # TLS is terminated by Thruster (bin/thrust, the container CMD) using a Let's Encrypt cert for
  # TLS_DOMAIN (defaulted from HOST in bin/docker-entrypoint), so the app sits behind SSL.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip the http-to-https redirect for the health check endpoint.
  config.ssl_options = {redirect: {exclude: ->(request) { request.path == "/up" }}}

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger($stdout)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = {database: {writing: :queue}}

  # The login flow emails a one-time code, so delivery errors must surface.
  config.action_mailer.raise_delivery_errors = true

  # Host for links in mailers — and the WebAuthn relying party derives from it (see
  # config/initializers/webauthn.rb), so this is also the passkey rp_id/origin. Falls back to
  # "localhost" so asset precompile can boot the env without HOST set; set HOST for a real deploy.
  config.action_mailer.default_url_options = {host: ENV.fetch("HOST", "localhost")}

  # Outgoing SMTP, configured from the environment (nil creds until set, so the env boots without
  # them; a real send then fails loudly via raise_delivery_errors if SMTP isn't configured).
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", "localhost"),
    port: ENV.fetch("SMTP_PORT", 587),
    user_name: ENV["SMTP_USER_NAME"],
    password: ENV["SMTP_PASSWORD"],
    authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain")
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks: only serve the configured host.
  config.hosts << ENV["HOST"] if ENV["HOST"].present?

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = {exclude: ->(request) { request.path == "/up" }}
end
