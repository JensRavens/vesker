class UploadsController < ApplicationController
  before_action :require_login
  before_action :set_album

  # The upload sidebar (lazy-loaded into the Shimmer modal).
  def new
    render Views::Albums::Upload.new(album: @album), layout: false
  end

  # One direct-uploaded blob per request (the row's turbo-frame form). Turn it into a moment unless
  # this album already holds the same file, then render the row's status back into its turbo frame.
  def create
    blob = ActiveStorage::Blob.find_signed!(params.require(:signed_id))
    existing = @album.moments.with_checksum(blob.checksum).first

    if existing
      blob.purge_later # nothing references this re-upload
      render Components::UploadStatus.new(state: :duplicate, frame_id:, message: duplicate_message(existing)), layout: false
    else
      (blob.video? ? Video : Photo).create!(album: @album, uploader: current_user, file: blob)
      render Components::UploadStatus.new(state: :done, frame_id:), layout: false
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render Components::UploadStatus.new(state: :failed, frame_id:), layout: false
  end

  private

  def set_album
    @album = Album.find_by!(slug: params[:album_id])
  end

  # Echo back the requesting frame so Turbo swaps the right row.
  def frame_id
    request.headers["Turbo-Frame"].presence || params[:frame_id]
  end

  def duplicate_message(moment)
    if moment.uploader_id == current_user.id
      t("components.upload_status.duplicate_self")
    else
      t("components.upload_status.duplicate", name: moment.uploader.name)
    end
  end
end
