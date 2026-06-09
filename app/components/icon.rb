module Components
  class Icon < Base
    # Available icons — each maps to an SVG file in icons/ that is masked in via CSS.
    NAMES = ["favorite", "favorite-outline", "comment", "comment-outline", "download",
      "play", "close", "link-off", "expand-more", "groups", "check-circle", "radio-unchecked",
      "alternate-email", "add-photo", "refresh", "error", "more-horiz", "share",
      "photo-library", "filter-none", "content-copy", "check", "info",
      "delete", "edit", "arrow-upward", "chevron-left", "chevron-right", "passkey"].freeze

    prop :name, _Union(*NAMES)
    prop :size, Integer, default: 16

    def view_template
      span(class: "icon icon--#{@name}", style: "width: #{@size}px; height: #{@size}px", aria_hidden: "true")
    end
  end
end
