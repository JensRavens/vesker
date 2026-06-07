class LikesController < ApplicationController
  before_action :require_login

  def create
    Like.find_or_create_by!(moment:, ownership:)
    redirect_to album_moment_path(@album, moment)
  rescue ActiveRecord::RecordNotUnique
    # Lost a race with a concurrent like — the row exists now, so just retry the find.
    retry
  end

  def destroy
    Like.where(moment:, ownership:).destroy_all
    redirect_to album_moment_path(@album, moment)
  end

  private

  def moment
    @moment ||= album.moments.find(params[:moment_id])
  end

  def album
    @album ||= Album.find_by!(slug: params[:album_id])
  end

  # The liking participant: a user who likes within an album joins it as a contributor.
  # find_or_create_by! (not create_or_find_by!) because Ownership has a uniqueness
  # validation that would raise RecordInvalid before the DB constraint is hit; the
  # rescue covers the rare concurrent first-time join.
  def ownership
    @ownership ||= album.ownerships.find_or_create_by!(user: current_user)
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def require_login
    head :unauthorized unless current_user
  end
end
