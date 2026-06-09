module Views
  class NotFound < Views::Base
    def view_template
      page_meta(title: t(".meta_title"))
      render Components::NotFound.new
    end
  end
end
