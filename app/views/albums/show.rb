module Views
  module Albums
    class Show < Views::Base
      prop :album, Album
      prop :moments, _Enumerable(Moment)
      prop :users, _Enumerable(User)
      prop :selected_user_ids, _Enumerable(String), default: -> { [] }

      def view_template
        render Components::Hero.new(
          album: @album, users: @users, moment_count: @moments.size, selected_user_ids: @selected_user_ids
        )
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
