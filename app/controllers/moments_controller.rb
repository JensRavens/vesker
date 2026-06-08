class MomentsController < ApplicationController
  before_action :require_login, only: [:confirm_delete, :destroy]

  def show
    @album = Album.find_by!(slug: params[:album_id])
    @moment = @album.moments.includes(:album, file_attachment: :blob, uploader: :user).find(params[:id])
    @comments = @moment.comments.order(created_at: :desc, id: :desc).includes(author: :user)
    @liked = current_user.present? && @moment.likes.joins(:ownership).exists?(ownerships: {user_id: current_user.id})

    render Views::Moments::Show.new(
      album: @album, moment: @moment, comments: @comments, liked: @liked
    )
  end

  # The confirm-delete modal (lazy-loaded into the Shimmer modal).
  def confirm_delete
    @album = Album.find_by!(slug: params[:album_id])
    @moment = @album.moments.find(params[:id])
    authorize @moment, :destroy?

    render Views::Moments::ConfirmDelete.new(album: @album, moment: @moment), layout: false
  end

  def destroy
    @album = Album.find_by!(slug: params[:album_id])
    @moment = @album.moments.find(params[:id])
    authorize @moment

    @moment.destroy
    redirect_to album_path(@album)
  end
end
