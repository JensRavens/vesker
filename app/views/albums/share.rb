module Views
  module Albums
    class Share < Views::Base
      prop :album, Album
      prop :url, String
      prop :qr_svg, String

      def view_template
        render Components::ShareCard.new(url: @url, qr_svg: @qr_svg)
      end
    end
  end
end
