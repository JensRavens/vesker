module Views
  module Albums
    class Show < Views::Base
      prop :album, Album
      prop :moments, _Enumerable(Moment)
      prop :users, _Enumerable(User)
      prop :selected_user_ids, _Enumerable(String), default: -> { [] }
      prop :pending_count, Integer, default: 0

      def view_template
        page_meta(
          title: @album.title,
          description: t(".meta_description", moments: @moments.size, people: @users.size),
          image: cover_file
        )

        # Newly-ready moments (and like/comment counts) morph in via this stream.
        turbo_stream_from(@album)

        render Components::Hero.new(
          album: @album, users: @users, moment_count: @moments.size,
          selected_user_ids: @selected_user_ids
        )
        render Components::ProcessingNotice.new(count: @pending_count) if @pending_count.positive?
        days.each { |date, moments| render Components::DaySection.new(date:, moments:) }
        render Components::Footer.new
      end

      private

      def days
        @moments.group_by { |moment| moment.captured_at.to_date }
      end

      # First photo as the social-preview image (videos can't be proxied to a still here).
      def cover_file
        @cover_file ||= @moments.find { |moment| moment.is_a?(Photo) }&.file
      end
    end
  end
end
