class MomentsController < ApplicationController
  def show
    @album = Album.find_by!(slug: params[:album_id])
    @moment = @album.moments.includes(:album, file_attachment: :blob, uploader: :user).find(params[:id])
    @comments = @moment.comments.order(:created_at, :id).includes(author: :user)

    render Views::Moments::Show.new(album: @album, moment: @moment, comments: @comments)
  end
end
