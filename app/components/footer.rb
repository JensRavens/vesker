module Components
  class Footer < Base
    def view_template
      footer(class: "footer") do
        text(type: "caption", element: :p) { t(".message") }
      end
    end
  end
end
