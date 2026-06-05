# CLAUDE.md

Guidance for working in this repo. Keep it current as conventions evolve.

## What this is

A **shared photo-album service** (working title "Mantel", built from a Claude Design handoff). People create an album, share an unguessable link, and everyone's photos/videos land in one timeline. There is **no public feed, no directory, no "my albums" dashboard** — the album's `slug` is the only way in.

Currently only the **model layer** is built (models, schema, concerns, seeds, tests). No controllers/routes/views yet.

## Stack

Rails 8.1 · Ruby 3.4 · **SQLite** · Hotwire (Turbo 8 + Stimulus) · Solid Queue/Cache/Cable · Active Storage. View layer (later) will be **Phlex** components.

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
- **`captured_at`** is denormalized onto `Moment` (NOT NULL) for SQL sorting (`scope :chronologic`). It defaults to `created_at` on create; `CaptureTimeAnalyzer` (a prepended Active Storage analyzer, pure-Ruby exifr) refines it from JPEG EXIF on upload, delegating to the original analyzer for the rest of the metadata.
- **Real-time** (later): structural changes (new/removed moment, rename) use Turbo 8 `broadcasts_refreshes`; likes/comments do a targeted replace of just the moment card.

## Domain model

`User` —(`Ownership`: role + color)— `Album` —< `Moment` (`Photo`/`Video`) —< `Comment`, `Like`. Album creator is derived from the ownership with `role: :creator`.

## Testing

- **Minitest specs with RSpec matchers.** Files are `class XxxTest < ActiveSupport::TestCase` using `describe`/`it` (Minitest spec DSL, enabled in `test/test_helper.rb`) and `expect(...).to ...` (`rspec/expectations/minitest_integration`). Group examples with nested `describe` (the equivalent of RSpec `context`).
- **Fixtures come from Oaken seeds**, not YAML. `db/seeds/albums.rb` builds one labelled "Lisbon & the Algarve" dataset shared by `bin/rails db:seed` and the test suite (`include Oaken.loader.test_setup`). Reference records as `albums.lisbon`, `users.priya`, `ownerships.priya`, `photos.tram`, `users.nomad` (a member-less user), etc. Lean on these instead of building graphs in tests.
- **Don't test Rails-guaranteed behavior** (counter caches, STI dispatch, `dependent: :destroy`, associations, standard validators). Test our own logic only.

## Style & tooling

- **RuboCop = Shimmer's StandardRB-based config** (`inherit_gem: { shimmer: config/rubocop_base.yml }`). Run `bin/rubocop`.
- **`# frozen_string_literal: true` is forbidden** (overridden to `EnforcedStyle: never`). Don't add it.
- **No future-implementation comments / dead-code stubs** in the code.
- **Models are annotated by `annotaterb`** (columns only — indexes and foreign keys are turned off; tests excluded). The schema block is regenerated automatically after `db:migrate`; run `bundle exec annotaterb models` to refresh manually.

## Common commands

```bash
bin/rails test test/models/ test/analyzers/   # run the model/analyzer specs
bin/rails db:migrate                           # also re-annotates models
bin/rails db:seed:replant                      # rebuild the Oaken dataset
bin/rubocop                                     # Shimmer/StandardRB lint
```

## Gotchas

- **`bin/rails test` (no args) fails** on `test:prepare → javascript:build`: `package.json` is a bare `bun init` with no `build` script (frontend bundling never set up). Run specs by path instead. Setting up the JS build is a separate task.
- **Video posters / capture-time for non-JPEG** need `ffmpeg` (+ a backend like libvips/ImageMagick) at runtime — not installed in this dev container, so those code paths are exercised only where the tooling exists.
- After changing a not-yet-committed migration, roll back the later domain migrations (`bin/rails db:rollback STEP=n`), edit, then `db:migrate` — the six domain migrations are uncommitted.
