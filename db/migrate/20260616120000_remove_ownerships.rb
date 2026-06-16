class RemoveOwnerships < ActiveRecord::Migration[8.1]
  def up
    # Re-point moments/comments/likes from the ownership join to the user directly,
    # backfilling each FK through the ownership it used to reference.
    remove_foreign_key :moments, column: :uploader_id
    execute "UPDATE moments SET uploader_id = (SELECT user_id FROM ownerships WHERE ownerships.id = moments.uploader_id)"
    add_foreign_key :moments, :users, column: :uploader_id

    remove_foreign_key :comments, column: :author_id
    execute "UPDATE comments SET author_id = (SELECT user_id FROM ownerships WHERE ownerships.id = comments.author_id)"
    add_foreign_key :comments, :users, column: :author_id

    remove_foreign_key :likes, :ownerships
    remove_index :likes, name: "index_likes_on_moment_id_and_ownership_id"
    remove_index :likes, name: "index_likes_on_ownership_id"
    execute "UPDATE likes SET ownership_id = (SELECT user_id FROM ownerships WHERE ownerships.id = likes.ownership_id)"
    rename_column :likes, :ownership_id, :user_id
    add_index :likes, [:moment_id, :user_id], unique: true
    add_index :likes, :user_id
    add_foreign_key :likes, :users

    # Site capability collapses to a single boolean: admin or not.
    add_column :users, :admin, :boolean, null: false, default: false
    execute "UPDATE users SET admin = 1 WHERE roles LIKE '%admin%'"
    remove_column :users, :roles

    drop_table :ownerships
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
