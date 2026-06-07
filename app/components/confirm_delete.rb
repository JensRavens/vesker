module Components
  class ConfirmDelete < Base
    include Phlex::Rails::Helpers::FormWith

    prop :album, Album
    prop :moment, Moment

    def view_template
      render ModalCard.new(icon: "delete", title: t(".title"), subhead: t(".body"), tone: :danger) do
        stack(gap: 9) do
          delete_form
          render Button.new(variant: :ghost, data: {controller: "modal", action: "modal#close"}) { t(".cancel") }
        end
      end
    end

    private

    def delete_form
      form_with(url: album_moment_path(@album, @moment), method: :delete) do |f|
        f.button(t(".confirm"), variant: :danger)
      end
    end
  end
end
