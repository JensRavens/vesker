# Contributing to Vesker

Thanks for your interest in improving Vesker! This is a small, conventional Rails app — if something
feels too hard, you're probably fighting the framework rather than working with it.

## Development setup

1. Use the [Dev Container](.devcontainer/) (it provides Ruby 4.0, Node 24, libvips, and ffmpeg), or
   install those yourself.
2. Install dependencies and seed a sample album:
   ```bash
   bundle install
   npm ci
   bin/rails db:prepare db:seed
   ```
3. Run the app with `bin/dev` (boots Rails + Vite + the Solid Queue worker) and open
   http://localhost:3000/albums/test. The dev login code is always `999999`.

## Conventions

Read [CLAUDE.md](CLAUDE.md) — it documents the architecture and the rules this codebase follows
(the nerdgeschoss [n.U.T.S handbook](https://nerdgeschoss.de/handbook/nuts)). In short:

- **Fat models, slim controllers.** Business logic lives in models and model-namespaced concerns,
  not service objects.
- **Views are [Phlex](https://www.phlex.fun) components** with colocated, BEM-named SCSS. Build
  forms with `form_with`; never hardcode user-facing strings (use `t(".key")`).
- **Pundit** is the authorization gate; policies tolerate a `nil` user and fail closed.
- No `# frozen_string_literal: true` magic comments. Comment only what isn't obvious.

## Testing

```bash
bin/rails test                              # model / policy / analyzer specs
PARALLEL_WORKERS=1 bin/rails test:system    # Playwright system tests
bin/rails test test/lint_test.rb            # RuboCop + Brakeman
```

- Tests are **Minitest with RSpec matchers** and **Oaken** seed data (no factories, no YAML
  fixtures). Use `expect(...).to ...`, never `assert_*`.
- Put logic in models/policies and unit-test it there; cover whole flows with a system spec. There
  are no controller/request specs.

## Pull requests

- Branch off `main`, keep the change focused, and make sure `bin/rails test` and `bin/rubocop`
  pass (CI runs Brakeman, bundler-audit, RuboCop, and the test suites).
- Match the style of the surrounding code. Update `CLAUDE.md` if you change a convention.

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
