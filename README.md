# Vesker

A **shared photo-album service**. Create an album, share its unguessable link, and everyone's
photos and videos land in one day-grouped timeline. There is **no public feed, no directory, and no
"my albums" dashboard** — the album's `slug` is the only way in. Viewing is always free; people are
only asked for an email (or a passkey) when they want to add photos or react.

Built with Rails 8.1, Hotwire (Turbo + Stimulus), [Phlex](https://www.phlex.fun) views, and
SQLite + the Solid trifecta (Queue/Cache/Cable) — a single-process, single-file deployment with no
external services.

## Features

- Day-grouped album timeline with a per-participant people-filter.
- Single-moment detail view with prev/next navigation, likes, and comments.
- Direct-to-storage uploads (drag-and-drop, concurrent, with retry) for photos and videos.
- Passwordless auth: an emailed one-time code, plus WebAuthn **passkeys**.
- Original capture-time extraction (EXIF for JPEG/HEIC via libvips; ffprobe for video).
- Share via QR code, bulk-download an album as a zip.

## Stack

Rails 8.1 · Ruby 4.0 · SQLite · Hotwire (Turbo 8 + Stimulus) · Solid Queue/Cache/Cable ·
Active Storage · [Vite](https://vite-ruby.netlify.app) (JS/CSS bundling) · Phlex (`phlex-rails` +
`literal`) · Pundit (authorization).

> **Conventions & architecture:** see [CLAUDE.md](CLAUDE.md). The project follows the
> nerdgeschoss [n.U.T.S handbook](https://nerdgeschoss.de/handbook/nuts) — fat models / slim
> controllers, concerns over service objects, Phlex components, Minitest + Oaken. It **deviates**
> from the handbook in a few deliberate ways: it uses **SQLite** rather than PostgreSQL, ships
> **JavaScript** Stimulus controllers (not TypeScript), and bundles no error/uptime monitoring
> (wire your own). It deploys with **Kamal** to a single server.

## Prerequisites

- **Ruby 4.0.1** (see `.ruby-version`)
- **Node 24** + npm (not Bun)
- **libvips** — image variants + HEIC EXIF
- **ffmpeg** — video posters, duration, and capture-time

The included [Dev Container](.devcontainer/) provides all of these.

## Getting started

```bash
bundle install
npm ci
bin/rails db:prepare db:seed   # creates the SQLite databases and a sample album
bin/dev                        # Rails + Vite + the Solid Queue worker
```

Open the seeded album at **http://localhost:3000/albums/test**. In development the emailed login
code is always **`999999`** (set by `LOGIN_CODE` in `.env.development`), so you can sign in without a
mail server. The site root (`/`) is the "Create an album" landing page — creating albums is
admin-only; the seeded admin is `marco@example.com`.

## Configuration

Settings are read through the `Config` constant (`Config.foo` → `ENV["FOO"]`, then the encrypted
credential `foo`). In **production**, secrets live in `config/credentials.yml.enc` (committed),
unlocked by `RAILS_MASTER_KEY`; edit them with `bin/rails credentials:edit`. See
[.env.example](.env.example) for the dev/non-secret variables. The essentials:

| Setting | Where | Purpose |
|---------|-------|---------|
| `HOST` | env (`deploy.yml` `env.clear`) | Public host — mailer links, the WebAuthn relying party, OG/share URLs. |
| `secret_key_base` | credentials | Signs/encrypts all cookies (sessions, login codes, WebAuthn challenges). |
| `smtp_address` / `smtp_port` / `smtp_user_name` / `smtp_password` / `smtp_authentication` | credentials | Outgoing mail (the login flow emails a code). |
| `LOGIN_CODE` | env, dev/test only | Forces a fixed login code. |

## Testing

```bash
bin/rails test                              # model / policy / analyzer + lint specs
PARALLEL_WORKERS=1 bin/rails test:system    # Playwright system tests (run npx playwright install chromium once)
bin/rails test test/lint_test.rb            # RuboCop + Brakeman as a test
```

## Deployment

Vesker deploys with **[Kamal](https://kamal-deploy.org)** to a single server (see
[config/deploy.yml](config/deploy.yml)). `kamal-proxy` terminates TLS (an automatic Let's Encrypt
cert for `HOST`) in front of the container; inside it, Thruster serves assets over HTTP and Puma
runs the Solid Queue worker. The image migrates the database on boot.

It deploys **without an external registry** — Kamal runs a local registry on the deploy machine and
the server pulls over the SSH tunnel. The build host is ARM and the server is AMD, so the image is
cross-built for `amd64` via emulation (`builder.arch: amd64`), which makes builds slow.

**Secrets** live in encrypted credentials; the only thing Kamal injects is `RAILS_MASTER_KEY` (read
from the local `config/master.key`). Before the first deploy:

```bash
bin/rails credentials:edit   # set secret_key_base + the smtp_* keys (real SMTP is required for login)
```

Then, with DNS for `HOST` pointing at the server and Docker (buildx + amd64 emulation) available
locally:

```bash
bin/kamal setup     # bootstraps the empty server (Docker, proxy, local registry) and deploys
bin/kamal deploy    # subsequent releases
```

**The `vesker_storage:/rails/storage` volume is mandatory** — every SQLite database *and* all
uploaded photos live under `storage/`, so without a persistent volume the entire dataset is lost on
redeploy. Back it up.

## License

[MIT](LICENSE) © 2026 Jens Ravens.
