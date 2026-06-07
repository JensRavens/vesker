module Components
  class ShareCard < Base
    prop :url, String
    prop :qr_svg, String

    def view_template
      div(class: "share-card") do
        text(type: "title3", element: :h2) { t(".title") }
        div(class: "share-card__qr") { raw(safe(@qr_svg)) }
        link_row
        info_row
      end
    end

    private

    def link_row
      div(class: "share-card__link") do
        span(class: "share-card__url") { @url }
        copy_button
      end
    end

    def copy_button
      button(type: "button", class: "share-card__copy",
        data: {controller: "clipboard", clipboard_text_value: @url, action: "clipboard#copy"}) do
        span(class: "share-card__copy-default") do
          icon(name: "content-copy", size: 16)
          text(type: "caption-bold", element: :span) { t(".copy") }
        end
        span(class: "share-card__copy-done") do
          icon(name: "check", size: 16)
          text(type: "caption-bold", element: :span) { t(".copied") }
        end
      end
    end

    def info_row
      div(class: "share-card__info") do
        icon(name: "info", size: 17)
        text(type: "caption", element: :span, color: "muted") { t(".info") }
      end
    end
  end
end
