class AlbumsController < ApplicationController
  def show
    @album = Album.find_by!(slug: params[:id])
    @users = @album.users
    @selected_user_ids = params[:people].to_s.split(",").select(&:present?)

    @moments = @album.moments.chronologic.includes(:album, :uploader, file_attachment: :blob)
    if @selected_user_ids.any?
      @moments = @moments.where(uploader_id: @album.ownerships.where(user_id: @selected_user_ids).select(:id))
    end

    render Views::Albums::Show.new(
      album: @album, moments: @moments, users: @users, selected_user_ids: @selected_user_ids
    )
  end

  # Popover content (lazy-loaded by the participants trigger).
  def people
    @album = Album.find_by!(slug: params[:id])
    @users = @album.users
    @selected_user_ids = params[:people].to_s.split(",").select(&:present?)

    render Components::PeoplePicker.new(album: @album, users: @users, selected_user_ids: @selected_user_ids), layout: false
  end
end
