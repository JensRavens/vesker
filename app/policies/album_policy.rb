# Creating and renaming albums are both restricted to site admins.
class AlbumPolicy < ApplicationPolicy
  def create?
    user&.admin? || false
  end

  def update?
    user&.admin? || false
  end
end
