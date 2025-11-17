class CreateReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :reminders do |t|
      t.integer :vehicle_id, null: false
      t.string :reminder_type, null: false
      t.date :due_date, null: false
      t.boolean :done, default: false, null: false

      t.timestamps
    end
    
    add_index :reminders, :vehicle_id
  end
end
