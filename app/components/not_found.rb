module Components
  class NotFound < Base
    def view_template
      div(class: "not-found") do
        text(type: "wordmark", element: :span) { t(".brand") }
        div(class: "not-found__body") do
          div(class: "not-found__badge") { icon(name: "link-off", size: 34) }
          text(type: "h2", element: :h1) { t(".title") }
          text(type: "body", element: :p, color: "secondary") { t(".message") }
        end
        text(type: "caption", element: :p) { t(".caption") }
      end
    end
  end
end
