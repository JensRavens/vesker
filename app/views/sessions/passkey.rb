module Views
  module Sessions
    class Passkey < Views::Base
      include Phlex::Rails::Helpers::TurboFrameTag
      include Phlex::Rails::Helpers::FormWith

      prop :passkey_options, _Nilable(Hash), default: nil
      prop :error, _Nilable(String), default: nil

      def view_template
        turbo_frame_tag "login" do
          render Components::ModalCard.new(icon: "passkey", title: t(".title"), subhead: t(".subhead")) do
            div(data: {controller: "passkey", passkey_options_value: @passkey_options.to_json}) do
              stack(gap: 12) do
                text(type: "caption-bold", color: "danger") { @error } if @error
                render Components::Button.new(variant: :primary, data: {action: "passkey#register"}) { t(".create") }
                render Components::Button.new(variant: :ghost, data: {action: "passkey#skip"}) { t(".skip") }
              end
              form_with(url: passkeys_path, method: :post, data: {passkey_target: "form"}) do |f|
                f.hidden_field :credential, data: {passkey_target: "credential"}
              end
            end
          end
        end
      end
    end
  end
end
