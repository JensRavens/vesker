module Components
  class MomentDetail < Base
    include Phlex::Rails::Helpers::FormWith

    prop :album, Album
    prop :moment, Moment
    prop :comments, _Enumerable(::Comment)
    prop :current_user, _Nilable(User), default: nil
    prop :liked, _Boolean, default: false

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
        like_button
        stat("comment-outline", @moment.comments_count, size: 22)
        download_button
      end
    end

    # Logged out → the heart opens the login modal. Logged in → it toggles a like
    # (the page morphs into the liked/unliked version on redirect).
    def like_button
      if @current_user
        like_form
      else
        button(
          type: "button", class: "moment-detail__stat moment-detail__like",
          aria_label: t(".like"),
          data: {controller: "modal", action: "modal#open", modal_url_value: new_session_path}
        ) { like_content }
      end
    end

    def like_form
      # form_with handles the CSRF token and the `_method` override for us.
      form_with(url: album_moment_like_path(@album, @moment), method: (@liked ? :delete : :post),
        class: "moment-detail__like-form") do
        button(
          type: "submit",
          class: "moment-detail__stat moment-detail__like#{" moment-detail__like--on" if @liked}",
          aria_label: @liked ? t(".unlike") : t(".like")
        ) { like_content }
      end
    end

    def like_content
      icon(name: @liked ? "favorite" : "favorite-outline", size: 24)
      text(type: "caption-bold", element: :span) { @moment.likes_count.to_s }
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
