class MoveAdminRoleToUsers < ActiveRecord::Migration[8.1]
  # `admin` was wrongly modelled as an album-scoped Ownership role. It's a site-wide
  # user capability, so it moves to a `roles` array on users; the Ownership enum keeps
  # only the album-scoped roles (contributor, creator).
  def up
    add_column :users, :roles, :json, null: false, default: []

    execute %(UPDATE users SET roles = '["admin"]' WHERE id IN (SELECT user_id FROM ownerships WHERE role = 1))
    execute "UPDATE ownerships SET role = 0 WHERE role = 1" # former admin → contributor
    execute "UPDATE ownerships SET role = 1 WHERE role = 2" # creator: 2 → 1
  end

  def down
    execute "UPDATE ownerships SET role = 2 WHERE role = 1" # creator: 1 → 2
    remove_column :users, :roles
  end
end
