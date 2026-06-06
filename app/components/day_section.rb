module Components
  class DaySection < Base
    prop :date, Date
    prop :moments, _Enumerable(Moment)

    def view_template
      section(class: "day-section") do
        div(class: "day-section__header", style: "view-transition-name: day-#{@date.iso8601}") do
          text(type: "caption-bold", element: :span) { l(@date, format: :album_day) }
          text(type: "caption", element: :span) { t(".item_count", count: @moments.size) }
        end
        div(class: "day-section__grid") do
          @moments.each { |moment| render MomentTile.new(moment:) }
        end
      end
    end
  end
end
