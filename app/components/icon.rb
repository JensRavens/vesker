module Components
  class Icon < Base
    # Available icons — each maps to an SVG file in icons/ that is masked in via CSS.
    NAMES = ["favorite", "comment", "play", "close", "link-off"].freeze

    prop :name, _Union(*NAMES)
    prop :size, Integer, default: 16

    def view_template
      span(class: "icon icon--#{@name}", style: "width: #{@size}px; height: #{@size}px", aria_hidden: "true")
    end
  end
end
