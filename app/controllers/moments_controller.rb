class MomentsController < ApplicationController
  def show
    @album = Album.find_by!(slug: params[:album_id])
    @moment = @album.moments.includes(uploader: :user, file_attachment: :blob).find(params[:id])
    @comments = @moment.comments.order(:created_at, :id).includes(author: :user)

    render Views::Moments::Show.new(album: @album, moment: @moment, comments: @comments)
  end
end
