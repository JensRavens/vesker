# CLAUDE.md

Guidance for working in this repo. Keep it current as conventions evolve.

## What this is

A **shared photo-album service** (built from a Claude Design handoff). People create an album, share an unguessable link, and everyone's photos/videos land in one timeline. There is **no public feed, no directory, no "my albums" dashboard** — the album's `slug` is the only way in.

Currently only the **model layer** is built (models, schema, concerns, seeds, tests). No controllers/routes/views yet.

## Stack

Rails 8.1 · Ruby 4.0 · **SQLite** · Hotwire (Turbo 8 + Stimulus) · Solid Queue/Cache/Cable · Active Storage. View layer (later) will be **Phlex** components.

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

## Testing

- **Minitest specs with RSpec matchers.** Files are `class XxxTest < ActiveSupport::TestCase` using `describe`/`it` (Minitest spec DSL, enabled in `test/test_helper.rb`) and `expect(...).to ...` (`rspec/expectations/minitest_integration`). Group examples with nested `describe` (the equivalent of RSpec `context`).
- **Fixtures come from Oaken seeds**, not YAML. `db/seeds/albums.rb` builds one labelled "Lisbon & the Algarve" dataset (real Unsplash photos from the prototype, in `db/seeds/files/photos/`, cycled across moments) shared by `bin/rails db:seed` and the test suite (`include Oaken.loader.test_setup`). Reference records as `albums.lisbon`, `users.priya`, `ownerships.priya`, `photos.tram`, `users.nomad` (a member-less user), etc. Lean on these instead of building graphs in tests.
- **Don't test Rails-guaranteed behavior** (counter caches, STI dispatch, `dependent: :destroy`, associations, standard validators). Test our own logic only.
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
bin/rails db:migrate                           # also re-annotates models
bin/rails db:seed:replant                      # rebuild the Oaken dataset
bin/rubocop                                     # Shimmer/StandardRB lint
```

## Gotchas

- **`bin/rails test` (no args) fails** on `test:prepare → javascript:build`: `package.json` is a bare `bun init` with no `build` script (frontend bundling never set up). Run specs by path instead. Setting up the JS build is a separate task.
- **Video posters / capture-time for non-JPEG** need `ffmpeg` at runtime; `libvips` is present as a library here (dimensions get extracted) but the `vips`/`ffmpeg` CLIs aren't — so those paths run only where the tooling exists.
- **Custom AS analyzer registration:** amend `config.active_storage.analyzers` inside `config.after_initialize` (`config/initializers/active_storage_analyzers.rb`) — the railtie copies config → `ActiveStorage.analyzers` in *its* after_initialize, so mutating the live array there gets overwritten.
- After changing a not-yet-committed migration, roll back the later domain migrations (`bin/rails db:rollback STEP=n`), edit, then `db:migrate` — the six domain migrations are uncommitted.
