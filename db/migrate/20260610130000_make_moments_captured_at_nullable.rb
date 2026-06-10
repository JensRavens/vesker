class MakeMomentsCapturedAtNullable < ActiveRecord::Migration[8.1]
  # captured_at is now set only once the file is analyzed and its representation warmed, so its
  # presence is what reveals a moment in the grid — hence nullable, with no upload-time default.
  def up
    change_column_null :moments, :captured_at, true
    change_column_default :moments, :captured_at, nil
  end

  def down
    change_column_default :moments, :captured_at, -> { "CURRENT_TIMESTAMP" }
    change_column_null :moments, :captured_at, false
  end
end
