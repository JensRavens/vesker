# Read capture time from image EXIF / video metadata on upload. Prepended so it wins for any
# image or video (it delegates to the original analyzer for the rest). We amend
# `config.active_storage.analyzers`, which Active Storage copies into `ActiveStorage.analyzers`
# during its own after_initialize.
Rails.application.config.after_initialize do
  Rails.application.config.active_storage.analyzers.prepend CaptureTimeAnalyzer
end
