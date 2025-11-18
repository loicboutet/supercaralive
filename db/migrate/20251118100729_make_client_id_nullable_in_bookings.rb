class MakeClientIdNullableInBookings < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bookings, :client_id, true
  end
end
