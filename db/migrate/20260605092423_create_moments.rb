class CreateMoments < ActiveRecord::Migration[8.1]
  def change
    create_table :moments, id: :string do |t|
      t.string :type, null: false                                   # STI: Photo / Video
      t.references :album, null: false, foreign_key: true, type: :string, index: false
      t.references :uploader, null: false, type: :string,
        foreign_key: {to_table: :ownerships}
      t.datetime :captured_at, null: false, default: -> { "CURRENT_TIMESTAMP" } # upload time; refined from EXIF
      t.integer :likes_count, null: false, default: 0
      t.integer :comments_count, null: false, default: 0

      t.timestamps
    end

    add_index :moments, [:album_id, :captured_at, :id]            # the chronologic timeline + keyset prev/next
    add_index :moments, :type
  end
end
