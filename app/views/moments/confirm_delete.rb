module Views
  module Moments
    class ConfirmDelete < Views::Base
      prop :album, Album
      prop :moment, Moment

      def view_template
        render Components::ConfirmDelete.new(album: @album, moment: @moment)
      end
    end
  end
end
