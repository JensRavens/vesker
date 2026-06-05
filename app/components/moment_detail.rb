module Components
  class MomentDetail < Base
    prop :album, Album
    prop :moment, Moment
    prop :comments, Enumerable

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
        if @moment.file.attached?
          image_tag(@moment.file, width: 1200, alt: "", class: "moment-detail__image",
            style: "view-transition-name: moment-#{@moment.id}")
        end
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
        render Avatar.new(ownership: @moment.uploader, size: 34)
        div(class: "moment-detail__byline") do
          text(type: "caption-bold", element: :span) { @moment.uploader.user.name }
          text(type: "caption", element: :span, color: "muted") { l(@moment.captured_at, format: :capture) }
        end
      end
    end

    def action_bar
      div(class: "moment-detail__actions") do
        stat("favorite", @moment.likes_count)
        stat("comment", @moment.comments_count)
      end
    end

    def stat(name, count)
      div(class: "moment-detail__stat") do
        icon(name:, size: 18)
        text(type: "caption-bold", element: :span) { count.to_s }
      end
    end

    def comment_list
      div(class: "moment-detail__comments") do
        @comments.each { |comment| render Comment.new(comment:) }
      end
    end
  end
end
