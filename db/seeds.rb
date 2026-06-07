# Seeds are defined with Oaken (see db/seeds/) and shared with the test suite.
# Both `bin/rails db:seed` and `bin/rails db:seed:replant` work as usual.
# Oaken is a dev/test-only gem, so this is a no-op in production (where db:prepare
# still runs seeds on a freshly created database).
Oaken.seed :albums if defined?(Oaken)
