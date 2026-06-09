# The app name Shimmer's meta helper appends to page titles ("<title> | Vesker") and uses
# as the Open Graph site title when a page sets no title of its own.
Shimmer::Meta.app_name = "Vesker"

# Shimmer's file proxy (OG image URLs) and the meta canonical build *absolute* URLs through the
# global route helpers, which have no request context — so they need a default host. Reuse the
# mailer's host so one config drives mailer links, the WebAuthn rp_id, and OG/file URLs.
Rails.application.routes.default_url_options.merge!(Rails.application.config.action_mailer.default_url_options)
