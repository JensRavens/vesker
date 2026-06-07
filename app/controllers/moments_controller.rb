class MomentsController < ApplicationController
  def show
    @album = Album.find_by!(slug: params[:album_id])
    @moment = @album.moments.includes(:album, file_attachment: :blob, uploader: :user).find(params[:id])
    @comments = @moment.comments.order(:created_at, :id).includes(author: :user)
    @liked = current_user.present? && @moment.likes.joins(:ownership).exists?(ownerships: {user_id: current_user.id})

    render Views::Moments::Show.new(
      album: @album, moment: @moment, comments: @comments,
      current_user:, liked: @liked
    )
  end
end
