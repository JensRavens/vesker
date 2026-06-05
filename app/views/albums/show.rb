module Views
  module Albums
    class Show < Views::Base
      prop :album, Album
      prop :moments, Enumerable
      prop :participants, Enumerable

      def view_template
        render Components::Hero.new(album: @album, participants: @participants, moment_count: @moments.size)
        days.each { |date, moments| render Components::DaySection.new(date:, moments:) }
        render Components::Footer.new
      end

      private

      def days
        @moments.group_by { |moment| moment.captured_at.to_date }
      end
    end
  end
end
