module Views
  module Sessions
    class Verify < Views::Base
      include Phlex::Rails::Helpers::TurboFrameTag
      include Phlex::Rails::Helpers::FormWith

      prop :email, _Nilable(String), default: nil
      prop :error, _Nilable(String), default: nil

      def view_template
        turbo_frame_tag "login" do
          render Components::ModalCard.new(icon: "alternate-email", title: t(".title"), subhead: t(".subhead", email: @email)) do
            stack(gap: 12) do
              form_with(url: verify_session_path, method: :patch) do |f|
                stack(gap: 14) do
                  text(type: "caption-bold", color: "danger") { @error } if @error
                  f.code_field :code, autofocus: true, maxlength: Login::EmailCode::CODE_LENGTH, placeholder: "·" * Login::EmailCode::CODE_LENGTH
                  f.button t(".submit")
                end
              end
              render Components::Button.new(variant: :ghost, href: new_session_path) { t(".change_email") }
            end
          end
        end
      end
    end
  end
end
