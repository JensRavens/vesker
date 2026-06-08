class Components::Base < Phlex::HTML
  extend Literal::Properties

  # Identity + authorization without prop drilling: `current_user` reads the per-request
  # user, and Pundit's `policy(record)` (whose `pundit_user` defaults to `current_user`)
  # is available directly, so a component asks `policy(album).update?` itself instead of
  # taking a `current_user`/`can_*` prop threaded down from the controller.
  include Pundit::Authorization

  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::Translate
  include Phlex::Rails::Helpers::L
  include Phlex::Rails::Helpers::Pluralize

  # Shimmer's image-proxy URL helper (used for video poster frames).
  register_value_helper :image_file_path

  def current_user
    Current.user
  end

  # n.U.T.S shorthands for the primitive components, so views read `text(...)` /
  # `stack(...)` / `icon(...)` instead of `render Components::Text.new(...)`.
  def text(**attributes, &)
    render(Components::Text.new(**attributes), &)
  end

  def stack(**attributes, &)
    render(Components::Stack.new(**attributes), &)
  end

  def box(**attributes, &)
    render(Components::Box.new(**attributes), &)
  end

  def icon(**attributes, &)
    render(Components::Icon.new(**attributes), &)
  end
end
