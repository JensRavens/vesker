module Views
  class NotFound < Views::Base
    def view_template
      render Components::NotFound.new
    end
  end
end
