class AlbumsController < ApplicationController
  include ZipKit::RailsStreaming
  include Shimmer::RemoteNavigation

  before_action :require_login, only: :create

  # The site root: a landing page prompting the visitor to create an album.
  def index
    render Views::Albums::Index.new
  end

  def create
    authorize Album, :create?

    redirect_to Album.create!
  end

  def show
    @album = Album.find_by!(slug: params[:id])
    @users = @album.users
    @selected_user_ids = params[:people].to_s.split(",").select(&:present?)
    @moments = @album.moments.ready.chronologic.includes(:album, :uploader, file_attachment: :blob)
    pending = @album.moments.pending
    if @selected_user_ids.any?
      @moments = @moments.where(uploader_id: @selected_user_ids)
      pending = pending.where(uploader_id: @selected_user_ids) # keep the count consistent with the filtered grid
    end
    @pending_count = pending.count

    render Views::Albums::Show.new(
      album: @album, moments: @moments, users: @users,
      selected_user_ids: @selected_user_ids, pending_count: @pending_count
    )
  end

  # Popover content (lazy-loaded by the participants trigger).
  def people
    @album = Album.find_by!(slug: params[:id])
    @users = @album.users
    @selected_user_ids = params[:people].to_s.split(",").select(&:present?)

    render Components::PeoplePicker.new(album: @album, users: @users, selected_user_ids: @selected_user_ids), layout: false
  end

  # Overflow-menu popover content (share + downloads). The component gates its rows itself
  # (the "except mine" row on login, the rename row on AlbumPolicy#update?).
  def menu
    @album = Album.find_by!(slug: params[:id])
    render Components::AlbumMenu.new(album: @album), layout: false
  end

  # The rename modal (lazy-loaded into the Shimmer modal), admin only.
  def edit
    @album = Album.find_by!(slug: params[:id])
    authorize @album, :edit?

    render Views::Albums::Edit.new(album: @album), layout: false
  end

  def update
    @album = Album.find_by!(slug: params[:id])
    authorize @album

    @album.update(params.expect(album: [:title]))
    ui.navigate_to(album_path(@album))
  end

  # Share/QR modal content. The QR encodes the full album URL so it scans from another device.
  def share
    @album = Album.find_by!(slug: params[:id])
    url = album_url(@album)
    qr = RQRCode::QRCode.new(url).as_svg(viewbox: true, use_path: true, color: "1a1611")
    render Views::Albums::Share.new(album: @album, url:, qr_svg: qr), layout: false
  end

  # Stream a zip of the album's media. ?scope=others drops the viewer's own uploads.
  def download
    @album = Album.find_by!(slug: params[:id])
    moments = @album.moments.ready.chronologic.includes(file_attachment: :blob)
    if params[:scope] == "others" && current_user
      moments = moments.where.not(uploader_id: current_user.id)
    end

    zip_kit_stream(filename: zip_filename) do |zip|
      seen = Hash.new(0)
      moments.each do |moment|
        next unless moment.file.attached?
        zip.write_file(unique_filename(moment.file.filename.to_s, seen)) do |sink|
          moment.file.download { |chunk| sink << chunk }
        end
      end
    end
  end

  private

  def zip_filename
    "#{@album.title.to_s.parameterize.presence || "album"}.zip"
  end

  # Disambiguate repeated filenames ("IMG.jpg", "IMG-1.jpg", …) so the zip has no collisions.
  def unique_filename(name, seen)
    seen[name] += 1
    return name if seen[name] == 1

    extension = File.extname(name)
    "#{File.basename(name, extension)}-#{seen[name] - 1}#{extension}"
  end
end
