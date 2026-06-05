module Components
  class Avatar < Base
    prop :ownership, Ownership
    prop :size, Integer, default: 28

    def view_template
      div(class: "avatar", style: "background: #{color}; --avatar-size: #{@size}px", title: @ownership.user.name) { initials }
    end

    private

    def color
      Palette.new.hex(@ownership.color)
    end

    def initials
      @ownership.user.name.split.first(2).filter_map { |part| part[0] }.join.upcase
    end
  end
end
