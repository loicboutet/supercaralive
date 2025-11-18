class MakeVehicleIdNullableInBookings < ActiveRecord::Migration[8.0]
  def change
    # Remove foreign key constraint first
    remove_foreign_key :bookings, :vehicles
    
    # Make vehicle_id nullable
    change_column_null :bookings, :vehicle_id, true
    
    # Re-add foreign key constraint (without NOT NULL)
    add_foreign_key :bookings, :vehicles, column: :vehicle_id
  end
end
