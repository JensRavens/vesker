module Components
  class Comment < Base
    prop :comment, ::Comment

    def view_template
      div(class: "comment") do
        render Avatar.new(user: @comment.author.user, color: @comment.author_color, size: 28)
        div(class: "comment__body") do
          div(class: "comment__meta") do
            text(type: "caption-bold", element: :span) { @comment.author.user.name }
            text(type: "caption", element: :span, color: "muted") { l(@comment.created_at, format: :comment) }
          end
          text(type: "body", element: :p) { @comment.body }
        end
      end
    end
  end
end
