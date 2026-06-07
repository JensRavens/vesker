module Views
  module Albums
    class Edit < Views::Base
      prop :album, Album

      def view_template
        render Components::RenameCard.new(album: @album)
      end
    end
  end
end
