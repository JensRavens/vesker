module Components
  # The result of a single upload, rendered by UploadsController and swapped into the row's turbo
  # frame: the moment was added, was a duplicate, or the blob was rejected. Self-wraps in a matching
  # turbo frame so Turbo replaces the right row.
  class UploadStatus < Base
    include Phlex::Rails::Helpers::TurboFrameTag

    prop :state, _Union(:done, :duplicate, :failed)
    prop :message, _Nilable(String), default: nil
    prop :frame_id, String

    ICONS = {done: "check-circle", duplicate: "info", failed: "error"}.freeze

    def view_template
      turbo_frame_tag(@frame_id) do
        span(class: "upload-status upload-status--#{@state}") do
          icon(name: ICONS[@state], size: 14)
          span(class: "upload-status__text") { @message || t(".#{@state}") }
        end
      end
    end
  end
end
