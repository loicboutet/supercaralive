class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.integer :user_id, null: false
      t.string :brand
      t.string :model
      t.integer :year
      t.integer :mileage
      t.string :vin_number
      t.date :next_maintenance_date
      t.date :next_technical_inspection_date
      t.text :upcoming_service
      t.boolean :maintenance_reminders_enabled, default: false

      t.timestamps
    end
    
    add_index :vehicles, :user_id
  end
end
