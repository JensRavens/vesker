module Components
  class PeoplePicker < Base
    prop :album, Album
    prop :users, _Enumerable(User)
    prop :selected_user_ids, _Enumerable(String), default: -> { [] }

    def view_template
      div(class: "people-picker") do
        div(class: "people-picker__header") do
          text(type: "caption-bold", element: :div, uppercase: true, color: "muted") { t(".header") }
        end
        everyone_row
        @users.each_with_index { |user, index| user_row(user, index) }
      end
    end

    private

    def palette
      @palette ||= Palette.new
    end

    def selected
      @selected_user_ids.to_a
    end

    def everyone_row
      a(href: album_path(@album), class: "people-picker__row") do
        icon(name: "groups", size: 18)
        text(type: "body", element: :span) { t(".everyone") }
        status(selected.empty?)
      end
    end

    def user_row(user, index)
      active = selected.empty? || selected.include?(user.id)
      a(href: toggle_path(user), class: "people-picker__row") do
        span(class: "people-picker__dot", style: "background: #{palette.hex(index)}")
        text(type: "body", element: :span) { user.name }
        status(active)
      end
    end

    def toggle_path(user)
      next_ids = selected.include?(user.id) ? selected - [user.id] : selected + [user.id]
      next_ids.empty? ? album_path(@album) : album_path(@album, people: next_ids.join(","))
    end

    def status(active)
      color = active ? "var(--color-accent)" : "var(--color-text-muted)"
      span(class: "people-picker__status", style: "color: #{color}") do
        icon(name: active ? "check-circle" : "radio-unchecked", size: 20)
      end
    end
  end
end
