class AddIndexToCustomAvailabilities < ActiveRecord::Migration[8.0]
  def change
    change_column_null :custom_availabilities, :date, false
    change_column_null :custom_availabilities, :start_time, false
    change_column_null :custom_availabilities, :end_time, false
    add_index :custom_availabilities, [:user_id, :date]
  end
end
