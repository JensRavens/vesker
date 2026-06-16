# == Schema Information
#
# Table name: albums
#
#  id         :string           not null, primary key
#  slug       :string           not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Album < ApplicationRecord
  # The slug is a random, unguessable token — it IS the access control. Not name-derived
  # (the title may be blank at creation). Stable across renames.
  has_secure_token :slug

  has_many :moments, dependent: :destroy

  def to_param
    slug
  end

  # The album's participants: everyone who has uploaded a moment, ordered by their first
  # upload (so index 0 is the first contributor). A user's index here maps to their palette
  # color. Memoized + materialized so the per-moment color lookup doesn't re-query the grid.
  def users
    @users ||= User
      .joins(:moments).where(moments: {album_id: id})
      .group("users.id").order(Arel.sql("MIN(moments.created_at)"))
      .to_a
  end
end
