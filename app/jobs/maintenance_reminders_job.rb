class MaintenanceRemindersJob < ApplicationJob
  queue_as :default

  def perform
    # Find all reminders that are not done
    reminders = Reminder.not_done.includes(vehicle: :user)
    
    reminders.each do |reminder|
      user = reminder.vehicle.user
      days_until_due = reminder.days_until_due
      
      # Handle upcoming reminder (15 days or less before due date)
      if days_until_due >= 0 && days_until_due <= 15 && !reminder.upcoming_reminder_sent?
        if user.maintenance_reminders_enabled?
          # Send email if user has enabled reminders
          MaintenanceReminderMailer.upcoming_reminder(reminder).deliver_now
        end
        # Mark as sent regardless of user preference (to avoid sending old alerts if they re-enable)
        reminder.update(upcoming_reminder_sent: true)
      end
      
      # Handle overdue reminder (1 day or more after due date)
      if days_until_due < 0 && !reminder.overdue_reminder_sent?
        if user.maintenance_reminders_enabled?
          # Send email if user has enabled reminders
          MaintenanceReminderMailer.overdue_reminder(reminder).deliver_now
        end
        # Mark as sent regardless of user preference (to avoid sending old alerts if they re-enable)
        reminder.update(overdue_reminder_sent: true)
      end
    end
  end
end

