module Components
  class ProcessingNotice < Base
    prop :count, Integer

    def view_template
      div(class: "processing-notice") do
        span(class: "processing-notice__spinner", aria_hidden: "true")
        text(type: "caption-bold", element: :span) { t(".message", count: @count) }
      end
    end
  end
end
