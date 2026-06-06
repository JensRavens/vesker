module Components
  class MomentDetail < Base
    prop :album, Album
    prop :moment, Moment
    prop :comments, _Enumerable(::Comment)

    def view_template
      div(class: "moment-detail") do
        media
        sidebar
      end
    end

    private

    def media
      div(class: "moment-detail__media") do
        a(href: album_path(@album), class: "moment-detail__close", aria_label: t(".close")) do
          icon(name: "close", size: 20)
        end
        if @moment.is_a?(Video)
          player
        elsif @moment.file.attached?
          image_tag(@moment.file, width: 1200, alt: "", class: "moment-detail__image",
            style: "view-transition-name: moment-#{@moment.id}")
        end
      end
    end

    def player
      video(class: "moment-detail__video", controls: true, playsinline: true, preload: "metadata",
        poster: image_file_path(@moment.file, width: 1200),
        style: "view-transition-name: moment-#{@moment.id}") do
        source(src: rails_blob_path(@moment.file), type: @moment.file.content_type)
      end
    end

    def sidebar
      aside(class: "moment-detail__sidebar") do
        header
        action_bar
        comment_list
      end
    end

    def header
      div(class: "moment-detail__header") do
        render Avatar.new(user: @moment.uploader.user, color: @moment.uploader_color, size: 34)
        div(class: "moment-detail__byline") do
          text(type: "caption-bold", element: :span) { @moment.uploader.user.name }
          text(type: "caption", element: :span, color: "muted") { l(@moment.captured_at, format: :capture) }
        end
      end
    end

    def action_bar
      div(class: "moment-detail__actions") do
        stat("favorite-outline", @moment.likes_count, size: 24)
        stat("comment-outline", @moment.comments_count, size: 22)
        download_button
      end
    end

    def stat(name, count, size:)
      div(class: "moment-detail__stat") do
        icon(name:, size:)
        text(type: "caption-bold", element: :span) { count.to_s }
      end
    end

    def download_button
      a(
        href: rails_blob_path(@moment.file, disposition: "attachment"),
        class: "moment-detail__download",
        download: @moment.file.filename.to_s,
        aria_label: t(".download")
      ) do
        icon(name: "download", size: 23)
      end
    end

    def comment_list
      div(class: "moment-detail__comments") do
        @comments.each { |comment| render Comment.new(comment:) }
      end
    end
  end
end
