class MomentsController < ApplicationController
  before_action :require_login, only: :destroy

  def show
    @album = Album.find_by!(slug: params[:album_id])
    @moment = @album.moments.includes(:album, file_attachment: :blob, uploader: :user).find(params[:id])
    @comments = @moment.comments.order(created_at: :desc, id: :desc).includes(author: :user)
    @liked = current_user.present? && @moment.likes.joins(:ownership).exists?(ownerships: {user_id: current_user.id})

    render Views::Moments::Show.new(
      album: @album, moment: @moment, comments: @comments, liked: @liked,
      previous_moment: neighbour(:before), next_moment: neighbour(:after)
    )
  end

  def destroy
    @album = Album.find_by!(slug: params[:album_id])
    @moment = @album.moments.find(params[:id])
    authorize @moment

    @moment.destroy
    redirect_to album_path(@album)
  end

  private

  # The adjacent moment in the album's chronologic order (keyset on captured_at + id,
  # the same sort the grid uses). Returns nil at the ends, so the arrow is hidden there.
  def neighbour(direction)
    scope = @album.moments
    t, i = @moment.captured_at, @moment.id
    if direction == :after
      scope.where("captured_at > :t OR (captured_at = :t AND id > :i)", t:, i:).order(:captured_at, :id).first
    else
      scope.where("captured_at < :t OR (captured_at = :t AND id < :i)", t:, i:).order(captured_at: :desc, id: :desc).first
    end
  end
end
