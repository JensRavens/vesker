# A moment can be deleted by the person who uploaded it or by the album's creator.
class MomentPolicy < ApplicationPolicy
  def destroy?
    return false unless user

    record.uploader.user_id == user.id || record.album.creator_ownership&.user_id == user.id
  end
end
