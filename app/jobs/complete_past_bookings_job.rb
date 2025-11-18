class CompletePastBookingsJob < ApplicationJob
  queue_as :default

  def perform
    # Find all bookings that are not completed but have a scheduled_at date/time in the past
    past_bookings = Booking.past_and_not_completed
    
    count = 0
    past_bookings.find_each do |booking|
      # Only update bookings that are not cancelled or refused (those should stay as is)
      if booking.status != 'cancelled' && booking.status != 'refused'
        booking.update(status: :completed)
        count += 1
      end
    end
    
    Rails.logger.info "CompletePastBookingsJob: #{count} booking(s) marked as completed"
  end
end

