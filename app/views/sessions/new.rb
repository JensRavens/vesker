module Views
  module Sessions
    class New < Views::Base
      include Phlex::Rails::Helpers::TurboFrameTag
      include Phlex::Rails::Helpers::FormWith

      def view_template
        turbo_frame_tag "login" do
          render Components::ModalCard.new(icon: "alternate-email", title: t(".title"), subhead: t(".subhead")) do
            stack(gap: 12) do
              form_with(url: session_path) do |f|
                stack(gap: 14) do
                  f.email_field :email, autofocus: true, placeholder: t(".placeholder")
                  f.button t(".submit")
                end
              end
              render Components::Button.new(variant: :ghost,
                data: {controller: "modal", action: "modal#close"}) { t(".dismiss") }
            end
          end
        end
      end
    end
  end
end
