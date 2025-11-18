class AddBookingReminderFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    # Champs pour les clients
    add_column :users, :client_booking_reminder, :boolean, default: true, null: false
    add_column :users, :client_booking_reminder_sent, :boolean, default: false, null: false
    
    # Champs pour les professionnels
    add_column :users, :professional_booking_notification, :boolean, default: true, null: false
    add_column :users, :professional_booking_reminder, :boolean, default: true, null: false
    add_column :users, :professional_booking_reminder_sent, :boolean, default: false, null: false
  end
end
