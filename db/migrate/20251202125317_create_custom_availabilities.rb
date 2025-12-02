class CreateCustomAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_availabilities do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps
    end
    
    add_index :custom_availabilities, [:user_id, :date]
  end
end
