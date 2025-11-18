class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.integer :client_id, null: false
      t.integer :professional_id, null: false
      t.references :vehicle, null: false, foreign_key: true
      t.references :professional_service, null: false, foreign_key: true
      t.string :status, default: "pending", null: false
      t.datetime :scheduled_at
      t.integer :current_mileage
      t.text :description
      t.decimal :estimated_price, precision: 8, scale: 2

      t.timestamps
    end
    
    add_foreign_key :bookings, :users, column: :client_id
    add_foreign_key :bookings, :users, column: :professional_id
    add_index :bookings, :client_id
    add_index :bookings, :professional_id
    add_index :bookings, :status
  end
end
