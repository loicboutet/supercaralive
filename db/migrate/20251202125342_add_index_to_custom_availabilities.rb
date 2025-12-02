class AddIndexToCustomAvailabilities < ActiveRecord::Migration[8.0]
  def change
    # Note: The index [:user_id, :date] is already created in the CreateCustomAvailabilities migration
    # These change_column_null calls ensure the columns are not null (they should already be null: false from the create_table)
    change_column_null :custom_availabilities, :date, false
    change_column_null :custom_availabilities, :start_time, false
    change_column_null :custom_availabilities, :end_time, false
  end
end
