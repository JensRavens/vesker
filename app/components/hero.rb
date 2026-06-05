module Components
  class Hero < Base
    prop :album, Album
    prop :participants, Enumerable
    prop :moment_count, Integer

    def view_template
      header(class: "hero") do
        text(type: "h1", element: :h1) { @album.title }
        div(class: "hero__people") do
          stack(line: true, gap: 0, align: "center") do
            @participants.each { |ownership| render Avatar.new(ownership:) }
          end
          text(type: "caption-bold", element: :span) do
            t(".summary", people: @participants.size, moments: @moment_count)
          end
        end
      end
    end
  end
end
