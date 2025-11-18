class AddClientReminderSentToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :client_reminder_sent, :boolean, default: false, null: false
  end
end
