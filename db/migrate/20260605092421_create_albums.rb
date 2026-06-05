class CreateAlbums < ActiveRecord::Migration[8.1]
  def change
    create_table :albums, id: :string do |t|
      t.string :title
      t.string :slug, null: false

      t.timestamps
    end

    add_index :albums, :slug, unique: true
  end
end
