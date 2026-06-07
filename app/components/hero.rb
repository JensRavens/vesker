module Components
  class Hero < Base
    prop :album, Album
    prop :users, _Enumerable(User)
    prop :moment_count, Integer
    prop :selected_user_ids, _Enumerable(String), default: -> { [] }
    prop :current_user, _Nilable(User), default: nil

    def view_template
      header(class: "hero") do
        div(class: "hero__top") do
          text(type: "h1", element: :h1) { @album.title }
          div(class: "hero__actions") do
            menu_button
            add_button
          end
        end
        button(type: "button", class: "hero__people", title: t(".filter"),
          data: {controller: "popover", popover_url_value: people_url, action: "popover#open"}) do
          stack(line: true, gap: 0, align: "center") do
            @users.each_with_index do |user, index|
              span(class: person_class(user)) { render Avatar.new(user:, color: palette.hex(index)) }
            end
          end
          text(type: "caption-bold", element: :span) { summary }
          icon(name: "expand-more", size: 18)
        end
      end
    end

    private

    # The ⋯ overflow menu: share + downloads (its rows are gated on login server-side).
    def menu_button
      button(type: "button", class: "hero__menu", title: t(".menu"),
        data: {controller: "popover", popover_url_value: menu_album_path(@album), action: "popover#open"}) do
        icon(name: "more-horiz", size: 22)
      end
    end

    # Logged out → opens the login modal; logged in → opens the upload sidebar.
    def add_button
      url = @current_user ? new_album_upload_path(@album) : new_session_path
      size = @current_user ? "sidebar" : ""
      button(type: "button", class: "hero__add", title: t(".add"),
        data: {controller: "modal", action: "modal#open", modal_url_value: url, modal_size_value: size}) do
        icon(name: "add-photo", size: 20)
        text(type: "caption-bold", element: :span) { t(".add") }
      end
    end

    def palette
      @palette ||= Palette.new
    end

    def selected
      @selected_user_ids.to_a
    end

    def filtering?
      selected.any?
    end

    def people_url
      people_album_path(@album, people: selected.join(","))
    end

    def person_class(user)
      dimmed = filtering? && !selected.include?(user.id)
      dimmed ? "hero__person hero__person--dimmed" : "hero__person"
    end

    def summary
      if filtering?
        t(".summary_filtered", selected: selected.size, total: @users.size)
      else
        t(".summary", people: @users.size, moments: @moment_count)
      end
    end
  end
end
