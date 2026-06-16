class CommentsController < ApplicationController
  before_action :require_login

  def create
    album = Album.find_by!(slug: params[:album_id])
    moment = album.moments.find(params[:moment_id])
    moment.comments.create!(comment_params.merge(author: current_user))
    redirect_to album_moment_path(album, moment)
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
