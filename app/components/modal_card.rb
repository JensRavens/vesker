module Components
  class ModalCard < Base
    prop :icon, _Union(*Icon::NAMES)
    prop :title, String
    prop :subhead, _Nilable(String), default: nil

    # Yields the body (a form, buttons, …) below the heading. The body composes
    # general components (Field via the form builder, Button) — the card styles none of them.
    def view_template(&)
      div(class: "modal-card") do
        stack(gap: 16, align: "center") do
          div(class: "modal-card__icon") do
            icon(name: @icon, size: 26)
          end
          stack(gap: 6, align: "center") do
            text(type: "title3", element: :h2) { @title }
            if @subhead
              div(class: "modal-card__subhead") do
                text(type: "subhead", element: :p) { @subhead }
              end
            end
          end
          div(class: "modal-card__body", &)
        end
      end
    end
  end
end
