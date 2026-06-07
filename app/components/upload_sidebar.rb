module Components
  class UploadSidebar < Base
    include Phlex::Rails::Helpers::FormWith

    prop :album, Album

    def view_template
      div(class: "upload-sidebar", data: controller_data) do
        header
        body
        footer
      end
    end

    private

    def controller_data
      {
        controller: "upload",
        upload_direct_upload_url_value: rails_direct_uploads_path,
        upload_labels_value: labels.to_json
      }
    end

    def header
      div(class: "upload-sidebar__header") do
        button(type: "button", class: "upload-sidebar__cancel",
          data: {controller: "modal", action: "modal#close"}) { t(".cancel") }
        text(type: "caption-bold", element: :span) { t(".title") }
        span(class: "upload-sidebar__count", data: {upload_target: "count"})
      end
    end

    def body
      div(class: "upload-sidebar__body") do
        dropzone
        ul(class: "upload-sidebar__list", data: {upload_target: "list"})
        row_template
      end
    end

    def dropzone
      div(class: "upload-sidebar__dropzone") do
        input(type: "file", id: "upload-files", multiple: true, accept: "image/*,video/*",
          class: "upload-sidebar__input", aria_label: t(".dropzone_title"),
          data: {upload_target: "input", action: "change->upload#filesChosen"})
        div(class: "upload-sidebar__dropzone-content") do
          span(class: "upload-sidebar__dropzone-icon") { icon(name: "add-photo", size: 26) }
          text(type: "caption-bold", element: :span) { t(".dropzone_title") }
          text(type: "caption", element: :span, color: "muted") { t(".dropzone_subhead") }
        end
      end
    end

    # One file row, cloned per upload by the Stimulus controller.
    def row_template
      template(data: {upload_target: "rowTemplate"}) do
        li(class: "upload-sidebar__row", data: {state: "queued"}) do
          div(class: "upload-sidebar__thumb")
          div(class: "upload-sidebar__info") do
            span(class: "upload-sidebar__name")
            div(class: "upload-sidebar__track") { div(class: "upload-sidebar__bar") }
            button(type: "button", class: "upload-sidebar__retry", data: {action: "upload#retry"}) do
              icon(name: "refresh", size: 15)
              text(type: "caption-bold", element: :span) { t(".retry") }
            end
          end
          span(class: "upload-sidebar__status") do
            span(class: "upload-sidebar__status-done") { icon(name: "check-circle", size: 14) }
            span(class: "upload-sidebar__status-failed") { icon(name: "error", size: 14) }
            span(class: "upload-sidebar__status-text")
          end
          button(type: "button", class: "upload-sidebar__remove", aria_label: t(".remove"),
            data: {action: "upload#removeFile"}) { icon(name: "close", size: 18) }
        end
      end
    end

    def footer
      div(class: "upload-sidebar__footer") do
        form_with(url: album_uploads_path(@album)) do |f|
          div(data: {upload_target: "fields"})
          f.button t(".submit"), disabled: true, data: {upload_target: "submit"}
        end
      end
    end

    def labels
      {
        queued: t(".status.queued"),
        done: t(".status.done"),
        failed: t(".status.failed"),
        submit: t(".submit"),
        submitUploading: t(".submit_uploading"),
        submitCount: t(".submit_count")
      }
    end
  end
end
