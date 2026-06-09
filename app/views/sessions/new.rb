module Views
  module Sessions
    class New < Views::Base
      include Phlex::Rails::Helpers::TurboFrameTag
      include Phlex::Rails::Helpers::FormWith

      prop :passkey_options, _Nilable(Hash), default: nil
      prop :error, _Nilable(String), default: nil

      def view_template
        div(data: {
          controller: "passkey",
          passkey_options_value: @passkey_options.to_json,
          passkey_mode_value: "conditional"
        }) do
          turbo_frame_tag "login" do
            render Components::ModalCard.new(icon: "alternate-email", title: t(".title"), subhead: t(".subhead")) do
              stack(gap: 12) do
                form_with(url: session_path, data: {action: "submit->passkey#abort"}) do |f|
                  stack(gap: 14) do
                    text(type: "caption-bold", color: "danger") { @error } if @error
                    f.email_field :email, autofocus: true, autocomplete: "username webauthn", placeholder: t(".placeholder")
                    f.button t(".submit")
                  end
                end
                render Components::Button.new(variant: :ghost,
                  data: {controller: "modal", action: "modal#close"}) { t(".dismiss") }
              end
            end
          end
          form_with(url: session_path, method: :post, data: {passkey_target: "form"}) do |f|
            f.hidden_field :credential, data: {passkey_target: "credential"}
          end
        end
      end
    end
  end
end
