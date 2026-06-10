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
  belongs_to :author, class_name: "Ownership", inverse_of: :comments

  validates :body, presence: true, length: {maximum: 5_000}

  # counter_cache bumps comments_count via raw SQL (no moment callback), so broadcast from here —
  # to the album (grid tile counts) and the moment (its detail page).
  broadcasts_refreshes_to ->(comment) { comment.moment.album }
  broadcasts_refreshes_to ->(comment) { comment.moment }

  # The author's color, derived from its position among the album's users.
  def author_color
    @author_color ||= Components::Palette.new.hex(moment.album.users.index { |user| user.id == author.user_id })
  end
end
