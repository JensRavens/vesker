# Only the album's creator can rename it.
class AlbumPolicy < ApplicationPolicy
  def update?
    user.present? && record.creator_ownership&.user_id == user.id
  end
end
