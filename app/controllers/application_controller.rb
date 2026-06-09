class ApplicationController < ActionController::Base
  include Shimmer::FileHelper
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Pundit::NotAuthorizedError, with: :head_forbidden

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

  # Controllers that need a signed-in user opt in with `before_action :require_login`.
  def require_login
    head :unauthorized unless current_user
  end

  # The page to morph back to after a modal action — the referer, but only if it's same-origin
  # (the `Referer` header is attacker-influenceable, so never navigate to an external host).
  def safe_referer
    referer = request.referer
    return root_path if referer.blank?

    host = URI.parse(referer).host
    (host.blank? || host == request.host) ? referer : root_path
  rescue URI::InvalidURIError
    root_path
  end

  private

  # Resolves the logged-in user (from the encrypted cookie) into the per-request Current.
  def authenticate
    Current.user = login.user
  end

  def render_not_found
    render Views::NotFound.new, status: :not_found
  end

  def head_forbidden
    head :forbidden
  end
end
