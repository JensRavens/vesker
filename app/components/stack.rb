module Components
  class Stack < Base
    BLOCK = "shimmer-components-stack".freeze

    prop :gap, Integer
    prop :gap_tablet, _Nilable(Integer), default: nil
    prop :gap_desktop, _Nilable(Integer), default: nil
    prop :gap_widescreen, _Nilable(Integer), default: nil
    prop :align, _Nilable(String), default: nil
    prop :align_tablet, _Nilable(String), default: nil
    prop :align_desktop, _Nilable(String), default: nil
    prop :align_widescreen, _Nilable(String), default: nil
    prop :justify, _Nilable(String), default: nil
    prop :justify_tablet, _Nilable(String), default: nil
    prop :justify_desktop, _Nilable(String), default: nil
    prop :justify_widescreen, _Nilable(String), default: nil
    prop :line, _Boolean, default: false
    prop :line_tablet, _Boolean, default: false
    prop :line_desktop, _Boolean, default: false
    prop :line_widescreen, _Boolean, default: false
    prop :wrap, _Boolean, default: false
    prop :wrap_tablet, _Boolean, default: false
    prop :wrap_desktop, _Boolean, default: false
    prop :wrap_widescreen, _Boolean, default: false
    prop :flex_grow, _Nilable(Integer), default: nil
    prop :flex_grow_tablet, _Nilable(Integer), default: nil
    prop :flex_grow_desktop, _Nilable(Integer), default: nil

    def view_template(&)
      div(class: css, style:, &)
    end

    private

    def css
      tokens = [BLOCK]
      tokens << "#{BLOCK}--justify-#{@justify}" if @justify
      tokens << "#{BLOCK}--justify-tablet-#{@justify_tablet}" if @justify_tablet
      tokens << "#{BLOCK}--justify-desktop-#{@justify_desktop}" if @justify_desktop
      tokens << "#{BLOCK}--justify-widescreen-#{@justify_widescreen}" if @justify_widescreen
      tokens << "#{BLOCK}--align-#{@align}" if @align
      tokens << "#{BLOCK}--align-tablet-#{@align_tablet}" if @align_tablet
      tokens << "#{BLOCK}--align-desktop-#{@align_desktop}" if @align_desktop
      tokens << "#{BLOCK}--align-widescreen-#{@align_widescreen}" if @align_widescreen
      tokens << "#{BLOCK}--line" if @line
      tokens << "#{BLOCK}--line-tablet" if @line_tablet
      tokens << "#{BLOCK}--line-desktop" if @line_desktop
      tokens << "#{BLOCK}--line-widescreen" if @line_widescreen
      tokens << "#{BLOCK}--wrap" if @wrap
      tokens << "#{BLOCK}--wrap-tablet" if @wrap_tablet
      tokens << "#{BLOCK}--wrap-desktop" if @wrap_desktop
      tokens << "#{BLOCK}--wrap-widescreen" if @wrap_widescreen
      tokens.join(" ")
    end

    def style
      tablet = @gap_tablet || @gap
      desktop = @gap_desktop || tablet
      widescreen = @gap_widescreen || desktop
      declarations = [
        "--gap: #{@gap}px",
        "--gap-tablet: #{tablet}px",
        "--gap-desktop: #{desktop}px",
        "--gap-widescreen: #{widescreen}px"
      ]
      if @flex_grow
        grow_tablet = @flex_grow_tablet || @flex_grow
        declarations << "--flex-grow: #{@flex_grow}"
        declarations << "--flex-grow-tablet: #{grow_tablet}"
        declarations << "--flex-grow-desktop: #{@flex_grow_desktop || grow_tablet}"
      end
      declarations.join("; ")
    end
  end
end
