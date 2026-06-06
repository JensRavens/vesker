module Components
  class MomentTile < Base
    prop :moment, Moment

    def view_template
      a(href: album_moment_path(@moment.album, @moment), class: "moment-tile",
        style: "background: #{gradient}; view-transition-name: moment-#{@moment.id}") do
        if @moment.file.attached?
          image_tag(@moment.file, width: 400, alt: "", class: "moment-tile__img")
        end
        span(class: "moment-tile__scrim")
        video_badge if video?
        counts if counts?
        span(class: "moment-tile__bar", style: "background: #{@moment.uploader_color}")
      end
    end

    private

    def video?
      @moment.is_a?(Video)
    end

    def gradient
      color = @moment.uploader_color
      "linear-gradient(135deg, #{color}, #{color}88)"
    end

    def counts?
      @moment.likes_count.positive? || @moment.comments_count.positive?
    end

    def video_badge
      span(class: "moment-tile__badge") do
        icon(name: "play", size: 12)
        text(type: "label", element: :span) { duration } if duration
      end
    end

    def duration
      seconds = @moment.duration&.to_i
      return unless seconds

      "#{seconds / 60}:#{(seconds % 60).to_s.rjust(2, "0")}"
    end

    def counts
      span(class: "moment-tile__counts") do
        if @moment.likes_count.positive?
          span(class: "moment-tile__count") do
            icon(name: "favorite", size: 13)
            text(type: "label", element: :span) { @moment.likes_count.to_s }
          end
        end
        if @moment.comments_count.positive?
          span(class: "moment-tile__count") do
            icon(name: "comment", size: 12)
            text(type: "label", element: :span) { @moment.comments_count.to_s }
          end
        end
      end
    end
  end
end
