# A moment can be deleted by the person who uploaded it, the album's creator, or any admin.
class MomentPolicy < ApplicationPolicy
  def destroy?
    return false unless user

    user.admin? ||
      record.uploader.user_id == user.id ||
      record.album.creator_ownership&.user_id == user.id
  end
end
