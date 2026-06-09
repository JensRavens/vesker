class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments, id: :string do |t|
      t.references :moment, null: false, foreign_key: true, type: :string, index: false
      t.references :author, null: false, type: :string,
        foreign_key: {to_table: :ownerships}
      t.text :body, null: false

      t.timestamps
    end

    add_index :comments, [:moment_id, :created_at]                # the newest-first list per moment
  end
end
