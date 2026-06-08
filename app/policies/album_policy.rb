# Creating an album is restricted to site admins. Renaming is allowed for the
# album's creator or any admin.
class AlbumPolicy < ApplicationPolicy
  def create?
    user&.admin? || false
  end

  def update?
    return false unless user

    user.admin? || record.creator_ownership&.user_id == user.id
  end
end
