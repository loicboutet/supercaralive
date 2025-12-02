class AddInterventionAddressToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :intervention_address, :text
  end
end
