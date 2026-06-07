class UploadsController < ApplicationController
  include Shimmer::RemoteNavigation

  before_action :require_login
  before_action :set_album

  # The upload sidebar (lazy-loaded into the Shimmer modal).
  def new
    render Views::Albums::Upload.new(album: @album), layout: false
  end

  # The files are already in storage (direct upload); turn each signed blob into a
  # moment, then close the modal and refresh the timeline.
  def create
    Array(params[:signed_ids]).reject(&:blank?).each do |signed_id|
      blob = ActiveStorage::Blob.find_signed!(signed_id)
      (blob.video? ? Video : Photo).create!(album: @album, uploader:, file: blob)
    end
    ui.navigate_to(album_path(@album))
  end

  private

  def set_album
    @album = Album.find_by!(slug: params[:album_id])
  end

  # The contributing participant: uploading joins the user to the album.
  def uploader
    @uploader ||= @album.ownership_for(current_user)
  end
end
