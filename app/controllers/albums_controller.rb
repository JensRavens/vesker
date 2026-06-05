class AlbumsController < ApplicationController
  def show
    @album = Album.find_by!(slug: params[:id])
    @moments = @album.moments.chronologic.includes(:album, :uploader, file_attachment: :blob)
    @participants = @album.ownerships.includes(:user)

    render Views::Albums::Show.new(album: @album, moments: @moments, participants: @participants)
  end
end
