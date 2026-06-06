module Components
  class Hero < Base
    prop :album, Album
    prop :users, _Enumerable(User)
    prop :moment_count, Integer
    prop :selected_user_ids, _Enumerable(String), default: -> { [] }

    def view_template
      header(class: "hero") do
        text(type: "h1", element: :h1) { @album.title }
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
