module Views
  module Albums
    class Index < Views::Base
      def view_template
        page_meta(description: t(".meta_description"))
        render Components::Landing.new
      end
    end
  end
end
