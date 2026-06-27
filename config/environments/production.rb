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

  # TLS is terminated by Cloudflare at the edge; it forwards X-Forwarded-Proto, so the app sits
  # behind SSL. kamal-proxy and Thruster both run HTTP-only at the origin.
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

  # Outgoing SMTP, read through Config (encrypted credentials in production; nil until set, so the
  # env boots without them — a real send then fails loudly via raise_delivery_errors if unconfigured).
  config.action_mailer.smtp_settings = {
    address: Config.smtp_address || "localhost",
    user_name: Config.smtp_user_name,
    password: Config.smtp_password,
    port: 587,
    authentication: :login,
    enable_starttls_auto: true
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
