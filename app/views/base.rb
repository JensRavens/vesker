class Views::Base < Components::Base
  def cache_store = Rails.cache

  private

  # Set the page's title / description / social-preview image via Shimmer's meta helper
  # (rendered by `render_meta` in the layout). The view and layout share one Rails view
  # context, so state set here is visible when the layout renders its <head>.
  def page_meta(title: nil, description: nil, image: nil)
    view_context.title(title) if title
    view_context.description(description) if description
    view_context.image(image) if image
  end
end
