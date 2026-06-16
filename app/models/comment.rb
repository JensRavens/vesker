# == Schema Information
#
# Table name: comments
#
#  id         :string           not null, primary key
#  body       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :string           not null
#  moment_id  :string           not null
#
class Comment < ApplicationRecord
  belongs_to :moment, counter_cache: true, inverse_of: :comments
  belongs_to :author, class_name: "User", inverse_of: :comments

  validates :body, presence: true, length: {maximum: 5_000}

  # counter_cache bumps comments_count via raw SQL (no moment callback), so broadcast from here —
  # to the album (grid tile counts) and the moment (its detail page).
  broadcasts_refreshes_to ->(comment) { comment.moment.album }
  broadcasts_refreshes_to ->(comment) { comment.moment }

  # The author's color, derived from its position among the album's users (its uploaders).
  # A comment-only author isn't an uploader, so they fall just past that list into the next slot.
  def author_color
    @author_color ||= begin
      users = moment.album.users
      Components::Palette.new.hex(users.index { |user| user.id == author_id } || users.size)
    end
  end
end
