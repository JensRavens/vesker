module Views
  module Albums
    class Index < Views::Base
      def view_template
        render Components::Landing.new
      end
    end
  end
end
