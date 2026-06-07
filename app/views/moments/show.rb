module Views
  module Moments
    class Show < Views::Base
      prop :album, Album
      prop :moment, Moment
      prop :comments, _Enumerable(::Comment)
      prop :current_user, _Nilable(User), default: nil
      prop :liked, _Boolean, default: false

      def view_template
        render Components::MomentDetail.new(
          album: @album, moment: @moment, comments: @comments,
          current_user: @current_user, liked: @liked
        )
      end
    end
  end
end
