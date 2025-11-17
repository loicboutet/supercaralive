class AddReminderSentFlagsToReminders < ActiveRecord::Migration[8.0]
  def change
    add_column :reminders, :upcoming_reminder_sent, :boolean, default: false, null: false
    add_column :reminders, :overdue_reminder_sent, :boolean, default: false, null: false
  end
end
