class Components::Base < Phlex::HTML
  extend Literal::Properties

  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::Translate
  include Phlex::Rails::Helpers::L
  include Phlex::Rails::Helpers::Pluralize

  # Shimmer's image-proxy URL helper (used for video poster frames).
  register_value_helper :image_file_path

  # n.U.T.S shorthands for the primitive components, so views read `text(...)` /
  # `stack(...)` / `icon(...)` instead of `render Components::Text.new(...)`.
  def text(**attributes, &)
    render(Components::Text.new(**attributes), &)
  end

  def stack(**attributes, &)
    render(Components::Stack.new(**attributes), &)
  end

  def icon(**attributes, &)
    render(Components::Icon.new(**attributes), &)
  end
end
