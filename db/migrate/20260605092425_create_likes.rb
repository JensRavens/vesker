class CreateLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :likes, id: :string do |t|
      t.references :moment, null: false, foreign_key: true, type: :string, index: false
      t.references :ownership, null: false, foreign_key: true, type: :string

      t.timestamps
    end

    add_index :likes, [:moment_id, :ownership_id], unique: true
  end
end
