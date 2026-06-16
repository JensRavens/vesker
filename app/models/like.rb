# == Schema Information
#
# Table name: likes
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  moment_id  :string           not null
#  user_id    :string           not null
#
class Like < ApplicationRecord
  belongs_to :moment, counter_cache: true, inverse_of: :likes
  belongs_to :user

  validates :user_id, uniqueness: {scope: :moment_id}

  # counter_cache bumps likes_count via raw SQL (no moment callback), so broadcast from here —
  # to the album (grid tile counts) and the moment (its detail page).
  broadcasts_refreshes_to ->(like) { like.moment.album }
  broadcasts_refreshes_to ->(like) { like.moment }
end
