class CreateOwnerships < ActiveRecord::Migration[8.1]
  def change
    create_table :ownerships, id: :string do |t|
      t.references :user, null: false, foreign_key: true, type: :string
      t.references :album, null: false, foreign_key: true, type: :string, index: false
      t.integer :role, null: false, default: 0
      t.integer :position, null: false
      t.integer :moments_count, null: false, default: 0

      t.timestamps
    end

    # One participation per user per album; also serves album-scoped lookups (legend/filter).
    add_index :ownerships, [:album_id, :user_id], unique: true
    # Positioning keeps `position` unique within the album scope.
    add_index :ownerships, [:album_id, :position], unique: true
  end
end
