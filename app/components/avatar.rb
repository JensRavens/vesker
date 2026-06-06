module Components
  class Avatar < Base
    prop :user, User
    prop :color, String
    prop :size, Integer, default: 28

    def view_template
      div(class: "avatar", style: "background: #{@color}; --avatar-size: #{@size}px", title: @user.name) { initials }
    end

    private

    def initials
      @user.name.split.first(2).filter_map { |part| part[0] }.join.upcase
    end
  end
end
