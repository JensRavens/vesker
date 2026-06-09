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
> from the handbook in a few deliberate ways: it uses **SQLite** rather than PostgreSQL, deploys as
> a **single Docker container** (not Dokku/Kamal), ships **JavaScript** Stimulus controllers (not
> TypeScript), and bundles no error/uptime monitoring (wire your own).

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

Settings are read through the `Config` constant (`Config.foo` → `ENV["FOO"]`). There are **no
encrypted Rails credentials** — production reads its secret from `SECRET_KEY_BASE`. See
[.env.example](.env.example) for every supported variable. The essentials:

| Variable | Purpose |
|----------|---------|
| `HOST` | Public host — used for mailer links, the WebAuthn relying party, OG/share URLs, and Thruster's TLS domain. |
| `SECRET_KEY_BASE` | Signs/encrypts all cookies (sessions, login codes, WebAuthn challenges). Required in production. |
| `SMTP_ADDRESS` / `SMTP_PORT` / `SMTP_USER_NAME` / `SMTP_PASSWORD` / `SMTP_AUTHENTICATION` | Outgoing mail (the login flow emails a code). |
| `LOGIN_CODE` | Dev/test only — forces a fixed login code. |

## Testing

```bash
bin/rails test                              # model / policy / analyzer + lint specs
PARALLEL_WORKERS=1 bin/rails test:system    # Playwright system tests (run npx playwright install chromium once)
bin/rails test test/lint_test.rb            # RuboCop + Brakeman as a test
```

## Deployment

Vesker deploys as a **single Docker container**. The image runs behind
[Thruster](https://github.com/basecamp/thruster), which terminates TLS (a Let's Encrypt cert for
`HOST`) and serves assets.

```bash
docker build -t vesker .
docker run -d -p 80:80 -p 443:443 \
  -v vesker-storage:/rails/storage \
  -e SECRET_KEY_BASE="$(bin/rails secret)" \
  -e HOST=album.example.com \
  -e SMTP_ADDRESS=smtp.example.com -e SMTP_USER_NAME=… -e SMTP_PASSWORD=… \
  --name vesker vesker
```

**The `-v vesker-storage:/rails/storage` volume is mandatory** — every SQLite database *and* all
uploaded photos live under `storage/`, so without a persistent volume the entire dataset is lost on
redeploy. Back up that volume. The container migrates the database on boot and runs the Solid Queue
worker inside Puma.

## License

[MIT](LICENSE) © 2026 Jens Ravens.
