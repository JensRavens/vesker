module Components
  # A single, app-wide <dialog> that backs Turbo's confirm (see application.js'
  # Turbo.setConfirmMethod). Rendered once in the layout; any `data-turbo-confirm`
  # on a form/link shows this styled dialog instead of the native browser confirm,
  # with its message swapped in. Reuses the design's danger ModalCard.
  class ConfirmDialog < Base
    def view_template
      dialog(id: "confirm-dialog", class: "confirm-dialog") do
        render ModalCard.new(icon: "delete", title: t(".title"), subhead: t(".message"), tone: :danger) do
          # method="dialog" closes the dialog on submit, reporting the pressed button's
          # value as returnValue — Turbo's promise resolves on "confirm".
          form(method: "dialog", class: "confirm-dialog__actions") do
            render Button.new(variant: :danger, type: :submit, value: "confirm") { t(".confirm") }
            render Button.new(variant: :ghost, type: :submit, value: "cancel") { t(".cancel") }
          end
        end
      end
    end
  end
end
