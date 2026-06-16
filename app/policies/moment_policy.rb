# A moment can be deleted by the person who uploaded it or any admin.
class MomentPolicy < ApplicationPolicy
  def destroy?
    return false unless user

    user.admin? || record.uploader_id == user.id
  end
end
