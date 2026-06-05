module Components
  class Text < Base
    # Semantic color names mapping to the `--color-*` tokens (see styles/tokens.scss).
    COLORS = {
      "default" => "--color-text",
      "secondary" => "--color-text-secondary",
      "muted" => "--color-text-muted"
    }.freeze

    prop :type, String
    prop :element, Symbol, default: :div
    prop :color, _Nilable(_Union(*COLORS.keys)), default: nil
    prop :uppercase, _Boolean, default: false
    prop :inline, _Boolean, default: false
    prop :no_wrap, _Boolean, default: false

    def view_template(&)
      public_send(@element, class: css, style: inline_style, &)
    end

    private

    def css
      classes = ["text", "text--#{@type}"]
      classes << "text--uppercase" if @uppercase
      classes << "text--inline" if @inline
      classes << "text--no-wrap" if @no_wrap
      classes.join(" ")
    end

    def inline_style
      return unless @color

      "color: var(#{COLORS.fetch(@color)})"
    end
  end
end
