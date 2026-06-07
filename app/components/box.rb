module Components
  # A spacing primitive: padding per side, per breakpoint. Use this (or Stack, for
  # spacing *between* components) instead of putting margins on — or reaching into —
  # other components. Each side cascades up the breakpoints like Stack's gap
  # (tablet falls back to base, desktop to tablet, widescreen to desktop).
  class Box < Base
    SIDES = {top: "t", right: "r", bottom: "b", left: "l"}.freeze
    BREAKPOINTS = [nil, :tablet, :desktop, :widescreen].freeze

    SIDES.each_key do |side|
      BREAKPOINTS.each do |breakpoint|
        prop [side, breakpoint].compact.join("_").to_sym, _Nilable(Integer), default: nil
      end
    end

    def view_template(&)
      div(class: "box", style:, &)
    end

    private

    def style
      SIDES.flat_map { |side, abbr| side_declarations(side, abbr) }.join("; ")
    end

    def side_declarations(side, abbr)
      base = padding(side)
      tablet = padding(side, :tablet) || base
      desktop = padding(side, :desktop) || tablet
      widescreen = padding(side, :widescreen) || desktop
      {nil => base, "-tablet" => tablet, "-desktop" => desktop, "-widescreen" => widescreen}
        .map { |suffix, value| "--box-p#{abbr}#{suffix}: #{value.to_i}px" }
    end

    def padding(side, breakpoint = nil)
      instance_variable_get(:"@#{[side, breakpoint].compact.join("_")}")
    end
  end
end
