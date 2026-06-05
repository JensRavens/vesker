# CLAUDE.md

Guidance for working in this repo. Keep it current as conventions evolve.

**This project does not use Claude memory files.** Anything worth remembering for next time — conventions, gotchas, decisions, preferences — goes in this file. If you learn something durable, add it here.

## What this is

A **shared photo-album service** (built from a Claude Design handoff). People create an album, share an unguessable link, and everyone's photos/videos land in one timeline. There is **no public feed, no directory, no "my albums" dashboard** — the album's `slug` is the only way in.

The **model layer** and the **first screen** (`Albums#show` — album title + day-grouped grid of photo/video previews) are built. The view layer is **Phlex** — see *View layer* below. Open the seeded album in dev at **`/albums/test`** (fixed slug).

## Stack

Rails 8.1 · Ruby 4.0 · **SQLite** · Hotwire (Turbo 8 + Stimulus) · Solid Queue/Cache/Cable · Active Storage · **Vite** (`vite_rails`) for JS/CSS bundling. View layer is **Phlex** (`phlex-rails` + `literal`).

## Conventions (n.U.T.S — nerdgeschoss handbook)

- **Fat models, slim controllers. Business logic lives in models — not service objects.** There is no `app/services`.
- **Concerns over service objects**, namespaced under their model: e.g. `User::Authentication` (`app/models/user/authentication.rb`), `Ownership::Palette`.
- **Schema reflects the domain, not the UI.** Normalize; don't carry UI-shaped denormalized data.
- Stick to Rails defaults. POROs are valid models when no persistence is needed.

## Architecture decisions (non-obvious)

- **UUID v7 primary keys on every table**, including Active Storage. SQLite has no native uuid, so they're generated app-side: `ApplicationRecord` has `before_create { self.id ||= SecureRandom.uuid_v7 }`, AS records get the same via `config/initializers/active_storage_uuid.rb`, and `config.generators` uses `primary_key_type: :string`. Migrations use `id: :string` and `type: :string` on references.
- **Passwordless auth (built later).** `User` has no password. Login is a one-time code emailed and held in the **session** — never persisted (no token/session table). The code's expiry is the controller's concern; the model (`User::Authentication`) only mints/verifies. Identity is email-only (`User.for_login`).
- **`Moment` is STI** (`type` column) with `Photo` and `Video` subclasses, one `has_one_attached :file` each.
- **`Ownership`** is the album-scoped participant (the "contributor"): it carries `role` (enum) and `color` (plain integer palette index, view maps it). Items/comments/likes reference the **Ownership**, not the global `User`, because role + color are per-album.
- **`captured_at`** (`Moment`, NOT NULL, **DB default `CURRENT_TIMESTAMP`** = upload time) is denormalized for SQL sorting (`scope :chronologic, -> { order(:captured_at, :id) }`). On upload, Active Storage's single `AnalyzeJob` runs `CaptureTimeAnalyzer` (prepended, pure-Ruby `exifr`; delegates to the original image analyzer for dimensions etc.), then the `activestorage-after_analyze_attached` gem fires `after_analyze_attached(:file)` — declared on **each STI subclass** (`Photo`/`Video`), since the gem's callback registry isn't inherited and attachments load as the subclass — which copies the EXIF time into the column. We never call `analyze` ourselves (avoids a double pass).
- **`User#name`** is auto-filled (when blank) from the email local-part, title-cased: `neo.m@… → "Neo M"`.
- **Real-time** (later, see plan): structural changes (new/removed moment, rename) use Turbo 8 `broadcasts_refreshes`; likes/comments do a targeted replace of just the moment card.

## Domain model

`User` —(`Ownership`: role + color)— `Album` —< `Moment` (`Photo`/`Video`) —< `Comment`, `Like`. Album creator is derived from the ownership with `role: :creator`.

## View layer (Phlex)

Set up in `config/initializers/phlex.rb`: two autoload namespaces — **`Components::`** (`app/components`, reusable building blocks) and **`Views::`** (`app/views`, one per controller action, e.g. `Views::Albums::Show`). `Components` is a `Phlex::Kit`. `Components::Base < Phlex::HTML` `extend`s `Literal::Properties` and includes the Phlex::Rails helpers (Routes, ImageTag, Translate, L, Pluralize); `Views::Base < Components::Base`.

- **Props via `prop` (literal gem):** `prop :name, Type`, read as `@name`. **Make props type-safe** — constrain enums with `_Union(*KEYS)` (e.g. `Text#color`, `Icon#name`) so an invalid value raises at construction. Collections are typed `Enumerable`.
- **Rendering:** primitives have lowercase shorthands defined on `Base` — `text(...)`, `stack(...)`, `icon(...)` — use those, not `render Components::Text.new`. Domain components use `render Components::X.new(...)`. The controller renders the page **view** directly (`render Views::Albums::Show.new(...)`); phlex-rails wraps it in the app layout. **All loading/eager-loading happens in the controller**, not in the view or model methods.
- **Colocated CSS:** every component ships a sibling `.scss` of the same basename (`hero.rb` + `hero.scss`), **no leading underscore**; the Vite entrypoint glob-imports `app/components/**/*.scss`. **Class name matches the component name** (root `.hero`, BEM children `.hero__people`; `DaySection` → `.day-section__header`/`.day-section__grid`). Components are **self-contained** — never style another component's classes from a different file. **Views carry no CSS** (they only orchestrate components); base element styles live in `app/frontend/styles/reset.css`.
- **Design tokens** (`app/frontend/styles/tokens.scss`) are `:root` CSS custom properties; **colors are prefixed `--color-`** with semantic names (`--color-background`, `--color-text`, `--color-text-secondary`, `--color-text-muted`, `--color-text-inverse`, `--color-chrome`, `--color-hairline`). Fonts (`--font-brand`/`--font-ui`) are defined in the **Text** component, not tokens.
- **i18n is component-relative:** `t(".key")` resolves to the component's path (`Components::Hero` → `components.hero.summary`); nest locale keys under `components.<name>`. Dates via `l(date, format: :album_day)` (format in `config/locales`). Never hardcode user-facing strings; never `strftime`.
- **Primitives:**
  - **`Text`** owns all typography **and the fonts**; variants `h1`/`body`/`caption-bold`/`caption`/`label`. `.text` sets no base color (it inherits; variants and the `color` prop override). `color` takes a semantic name (`default`/`secondary`/`muted`) mapped to a `--color-*` token.
  - **`Stack`** is the canonical shimmer component (class `.shimmer-components-stack`, copied verbatim from `nerdgeschoss/shimmer-components`): `gap` is an inline `--gap` custom property, with responsive `*_tablet/_desktop/_widescreen` props (breakpoints 640/890/1280).
  - **`Icon`** renders a `<span>` masked by an SVG file in `app/components/icons/` (`mask-image: url("./icons/<name>.svg")`, tinted via `background-color: currentColor`). Add an icon = drop an SVG in that folder + a `.icon--<name>` rule + extend `Icon::NAMES`.
- **Contributor colors:** `Components::Palette` (plain class) maps an `Ownership#color` index to a hex — `Palette.new.hex(index)` / `.gradient(index)`; index 0 is the album owner (ember), the rest cycle the remaining colors. These per-contributor hexes live in Ruby and are emitted as inline `style` (distinct from the `--color-*` UI chrome tokens).
- **Images via shimmer:** `image_tag(attachment, width: 400)` uses shimmer's `image_tag` override (webp proxy, lazy, 2× srcset) — activated by `include Shimmer::FileHelper` in `ApplicationController`, served via the `file` route (`get "files/:id" => "shimmer/files#show"`). The proxy uses `resize_to_limit`; square tiles crop via CSS `object-fit: cover`. Video posters need ffmpeg.

## Testing

- **Minitest specs with RSpec matchers.** Files are `class XxxTest < ActiveSupport::TestCase` using `describe`/`it` (Minitest spec DSL, enabled in `test/test_helper.rb`) and `expect(...).to ...` (`rspec/expectations/minitest_integration`). Group examples with nested `describe` (the equivalent of RSpec `context`).
- **Fixtures come from Oaken seeds**, not YAML. `db/seeds/albums.rb` builds one labelled "Lisbon & the Algarve" dataset shared by `bin/rails db:seed` and the test suite (`include Oaken.loader.test_setup`). The album has a fixed `slug: "test"`. Photos (`db/seeds/files/photos/`) are cycled across moments; **video moments attach a real clip** (`db/seeds/files/videos/movie-short.mp4`) and are analyzed up front (`record.file.blob.analyze`) so `duration` is available — needs ffmpeg. The first two days are tripled → **33 moments** total. Reference records as `albums.lisbon`, `users.priya`, `ownerships.priya`, `photos.tram`, `users.nomad` (a member-less user), etc.
- **Don't test Rails-guaranteed behavior** (counter caches, STI dispatch, `dependent: :destroy`, associations, standard validators). Test our own logic only.
- **System tests** (`test/system/`, Minitest) drive a real Chromium via **Playwright** (`capybara-playwright-driver`). The driver is registered as `:vesker_playwright` in `test/application_system_test_case.rb` — **don't name it `:playwright`** (the gem reserves that). The browser is installed once with `npx playwright install chromium`. They are **not** in the default `bin/rails test`; run `bin/rails test:system` (prefer `PARALLEL_WORKERS=1`). Keep them behavioral — no screenshots in committed tests.
- **Lint test** (`test/lint_test.rb`) runs `bin/rubocop` and `bin/brakeman` via `Open3.capture2e` and asserts a clean exit — silent on success, surfacing the tool output only on failure. It uses `assert …, output` (not `expect`) so the failure message carries the offenses. There's one EXIF fixture with a real capture time: `test/fixtures/files/exif_sample.jpg`.

## Style & tooling

- **RuboCop = Shimmer's StandardRB-based config** (`inherit_gem: { shimmer: config/rubocop_base.yml }`, via the `standard` + `rubocop-rails` gems). Run `bin/rubocop`.
- **`# frozen_string_literal: true` is forbidden** (overridden to `EnforcedStyle: never`). Don't add it.
- **No future-implementation comments / dead-code stubs** in the code.
- **Models are annotated by `annotaterb`** (columns only — indexes and foreign keys are turned off; tests excluded). The schema block is regenerated automatically after `db:migrate`; run `bundle exec annotaterb models` to refresh manually.
- **Gemfile** is organized by section: gems grouped under `# Core` / `# Database` / `# Extensions` / `# Assets` / `# Deployment` comments (no per-gem comments), then `:development,:test` / `:development` / `:test` groups (annotaterb and the rubocop/brakeman tools are `require: false`).

## Common commands

```bash
bin/rails test test/models/ test/analyzers/   # run the model/analyzer specs
bin/rails test test/lint_test.rb               # rubocop + brakeman as a test
PARALLEL_WORKERS=1 bin/rails test:system       # Playwright system tests (not in `rails test`)
bin/rails db:migrate                           # also re-annotates models
bin/rails db:seed:replant                      # rebuild the Oaken dataset
bin/vite dev                                    # asset dev server (do NOT `bin/vite build`)
bin/rubocop                                     # Shimmer/StandardRB lint
```

## Frontend

JS/assets are bundled with **Vite** (`vite_rails`): entrypoint `app/frontend/entrypoints/application.js` (imports `reset.css` + `tokens.scss`, then glob-imports `app/components/**/*.scss`), config in `config/vite.json` + `vite.config.ts`, loaded in the layout via `vite_client_tag` + `vite_javascript_tag "application"`. SCSS via the `sass` npm dep. JS deps are managed with **npm** (node 24 / npm 11; not Bun). Hotwire JS isn't imported in the entrypoint yet — wire `@hotwired/turbo-rails`/Stimulus there when interactivity lands.

- **Never run `bin/vite build`.** The dev server (`bin/vite dev`) serves assets automatically (the Rails proxy is on — no `skipProxy` in `config/vite.json`), and tests use the test-env auto-build. Running `bin/vite build` writes stale compiled output into `public/vite*` that later masks your real changes and causes confusing debugging. To verify CSS/JS, use the dev server or run a system test.
- **Don't hand-write vendor prefixes** (`-webkit-`, etc.). `autoprefixer` (`postcss.config.js` + the `browserslist` in `package.json`) adds them automatically.

## Gotchas

- **Video posters / duration / capture-time for non-JPEG** need the `ffmpeg` CLI at runtime (now installed here — `apt-get install ffmpeg`; not guaranteed in CI). `libvips` is present as a library (image variants/dimensions work) but the `vips` CLI isn't. Without ffmpeg the video seed still loads, but `Video#duration` and the poster frame come back empty.
- **Custom AS analyzer registration:** amend `config.active_storage.analyzers` inside `config.after_initialize` (`config/initializers/active_storage_analyzers.rb`) — the railtie copies config → `ActiveStorage.analyzers` in *its* after_initialize, so mutating the live array there gets overwritten.
- After changing a not-yet-committed migration, roll back the later domain migrations (`bin/rails db:rollback STEP=n`), edit, then `db:migrate` — the six domain migrations are uncommitted.
