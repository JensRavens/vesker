module Components
  class Landing < Base
    include Phlex::Rails::Helpers::FormWith

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

    # Creating is admin-only. A guest sees the button and it opens the login modal (an
    # admin can then sign in and create); a signed-in admin gets a button that POSTs a new
    # album; a signed-in non-admin sees no button at all.
    def create_button
      if current_user.nil?
        render Button.new(data: {controller: "modal", action: "modal#open", modal_url_value: new_session_path}) do
          create_label
        end
      elsif policy(Album).create?
        form_with(url: albums_path, method: :post) do |f|
          f.button { create_label }
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
