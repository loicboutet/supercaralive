class AddProfessionalReminderSentToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :professional_reminder_sent, :boolean, default: false, null: false
  end
end
