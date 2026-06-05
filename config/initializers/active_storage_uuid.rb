# Active Storage's own records don't inherit from ApplicationRecord, so give them
# the same app-side UUID v7 primary keys (the whole primary DB is string-uuid).
[:active_storage_blob, :active_storage_attachment, :active_storage_variant_record].each do |hook|
  ActiveSupport.on_load(hook) do
    before_create { self.id ||= SecureRandom.uuid_v7 }
  end
end
