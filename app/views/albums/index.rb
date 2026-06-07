module Views
  module Albums
    class Index < Views::Base
      prop :current_user, _Nilable(User), default: nil

      def view_template
        render Components::Landing.new(current_user: @current_user)
      end
    end
  end
end
