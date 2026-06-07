class ApplicationController < ActionController::Base
  include Shimmer::FileHelper

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :authenticate

  helper_method :current_user

  protected

  # Subclasses (e.g. LikesController) read this; helpers/views go through helper_method.
  def current_user
    Current.user
  end

  # The login for this request (owns cookies/code/email); shared by authenticate + SessionsController.
  def login
    @login ||= Login.new(cookies)
  end

  private

  # Resolves the logged-in user (from the encrypted cookie) into the per-request Current.
  def authenticate
    Current.user = login.user
  end

  def render_not_found
    render Views::NotFound.new, status: :not_found
  end
end
