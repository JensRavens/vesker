module Views
  module Albums
    class Upload < Views::Base
      prop :album, Album

      def view_template
        render Components::UploadSidebar.new(album: @album)
      end
    end
  end
end
