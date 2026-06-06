module Views
  module Moments
    class Show < Views::Base
      prop :album, Album
      prop :moment, Moment
      prop :comments, _Enumerable(::Comment)

      def view_template
        render Components::MomentDetail.new(album: @album, moment: @moment, comments: @comments)
      end
    end
  end
end
