module Views
  module Moments
    class Show < Views::Base
      prop :album, Album
      prop :moment, Moment
      prop :comments, _Enumerable(::Comment)
      prop :liked, _Boolean, default: false
      prop :previous_moment, _Nilable(Moment), default: nil
      prop :next_moment, _Nilable(Moment), default: nil

      def view_template
        page_meta(title: @album.title, image: @moment.file)

        # Likes/comments on this moment morph the page in live.
        turbo_stream_from(@moment)

        render Components::MomentDetail.new(
          album: @album, moment: @moment, comments: @comments, liked: @liked,
          previous_moment: @previous_moment, next_moment: @next_moment
        )
      end
    end
  end
end
