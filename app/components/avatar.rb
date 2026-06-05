module Components
  class Avatar < Base
    prop :ownership, Ownership

    def view_template
      div(class: "avatar", style: "background: #{color}", title: @ownership.user.name) { initials }
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
