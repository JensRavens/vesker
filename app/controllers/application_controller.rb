class ApplicationController < ActionController::Base
  include Shimmer::FileHelper

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_not_found
    render Views::NotFound.new, status: :not_found
  end
end
