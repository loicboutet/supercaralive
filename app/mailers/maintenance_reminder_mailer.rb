class MaintenanceReminderMailer < ApplicationMailer
  def upcoming_reminder(reminder)
    @reminder = reminder
    @user = reminder.vehicle.user
    @vehicle = reminder.vehicle
    @reminder_type = reminder.reminder_type == 'maintenance' ? 'entretien' : 'contrôle technique'
    
    mail(to: @user.email, subject: "Rappel : #{@reminder_type.capitalize} à prévoir pour votre #{@vehicle.brand} #{@vehicle.model}")
  end

  def overdue_reminder(reminder)
    @reminder = reminder
    @user = reminder.vehicle.user
    @vehicle = reminder.vehicle
    @reminder_type = reminder.reminder_type == 'maintenance' ? 'entretien' : 'contrôle technique'
    
    mail(to: @user.email, subject: "URGENT : #{@reminder_type.capitalize} en retard pour votre #{@vehicle.brand} #{@vehicle.model}")
  end
end

