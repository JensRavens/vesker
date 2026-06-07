module Components
  class RenameCard < Base
    include Phlex::Rails::Helpers::FormWith

    prop :album, Album

    def view_template
      render ModalCard.new(icon: "edit", title: t(".title")) do
        form_with(model: @album) do |f|
          stack(gap: 14) do
            f.text_field :title, autofocus: true, value: @album.title, placeholder: t(".placeholder")
            f.button t(".save")
          end
        end
      end
    end
  end
end
