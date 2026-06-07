module Components
  class Landing < Base
    prop :current_user, _Nilable(User), default: nil

    def view_template
      div(class: "landing") do
        div(class: "landing__glow")
        div(class: "landing__content") do
          stack(gap: 24, align: "center") do
            div(class: "landing__badge") { icon(name: "photo-library", size: 34) }
            stack(gap: 12, align: "center") do
              text(type: "h1", element: :h1) { t(".title") }
              div(class: "landing__subhead") do
                text(type: "subhead", element: :p) { t(".subhead") }
              end
            end
            div(class: "landing__actions") { create_button }
          end
        end
        text(type: "caption", element: :p) { t(".footer") }
      end
    end

    private

    # Logged in → a link to the auto-create path; logged out → opens the login modal first
    # (after sign-in the page morphs and the button becomes the create link).
    def create_button
      if @current_user
        render Button.new(href: new_album_path) { create_label }
      else
        render Button.new(data: {controller: "modal", action: "modal#open", modal_url_value: new_session_path}) do
          create_label
        end
      end
    end

    def create_label
      span(class: "landing__create") do
        icon(name: "add-photo", size: 20)
        span { t(".create") }
      end
    end
  end
end
