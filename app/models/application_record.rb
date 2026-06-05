class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # UUID v7 primary keys, generated app-side (SQLite has no native uuid type).
  before_create { self.id ||= SecureRandom.uuid_v7 }
end
