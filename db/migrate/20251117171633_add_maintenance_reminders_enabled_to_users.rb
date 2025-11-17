class AddMaintenanceRemindersEnabledToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :maintenance_reminders_enabled, :boolean, default: true, null: false
  end
end
