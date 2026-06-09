# Configure the WebAuthn relying party once, inferred from the app's URL settings (the
# same host/port URL helpers and mailer links use) — so there's no per-request setup and
# no separate ENV to keep in sync. Set the host per environment via
# `config.action_mailer.default_url_options` (localhost in dev, the real domain in prod).
url_options = Rails.application.config.action_mailer.default_url_options || {}
host = url_options[:host]
port = url_options[:port]
protocol = url_options[:protocol] || ((host == "localhost") ? "http" : "https")
origin = port ? "#{protocol}://#{host}:#{port}" : "#{protocol}://#{host}"

WebAuthn.configure do |config|
  config.allowed_origins = [origin]
  config.rp_id = host
  config.rp_name = "Vesker"
end
