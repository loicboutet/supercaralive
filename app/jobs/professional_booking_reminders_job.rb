class ProfessionalBookingRemindersJob < ApplicationJob
  queue_as :default

  def perform
    # Find all bookings that are scheduled in 7 days or less
    # and haven't had their reminder sent yet
    seven_days_from_now = 7.days.from_now
    
    bookings = Booking
      .where(status: [:pending, :accepted])
      .where("scheduled_at <= ? AND scheduled_at >= ?", seven_days_from_now, Time.current)
      .where(professional_reminder_sent: false)
      .includes(:professional, :client, :vehicle, :professional_service)
    
    bookings.each do |booking|
      # Only send if professional has enabled reminders
      if booking.professional.professional_booking_reminder?
        BookingMailer.professional_booking_reminder(booking).deliver_now
        
        # Mark reminder as sent for this specific booking
        booking.update(professional_reminder_sent: true)
      end
    end
  end
end

