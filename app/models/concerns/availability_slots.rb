module AvailabilitySlots
  extend ActiveSupport::Concern

  included do
    # Calculate available time slots for a professional service
    # Returns a hash with dates as keys and arrays of available time slots as values
    def available_time_slots_for_service(professional_service, month: Date.current.month, year: Date.current.year, exclude_booking_id: nil)
      return {} unless professional_service.present? && professional_service.user_id == id
      
      duration_minutes = professional_service.duration_minutes || 60 # Default to 1 hour
      
      # Get all availabilities for this professional (load into array to avoid ActiveRecord relation issues)
      professional_availabilities = availabilities.order(:day_of_week, :start_time).to_a
      
      return {} if professional_availabilities.empty?
      
      # Get existing bookings that could conflict (accepted or pending)
      conflicting_bookings = professional_bookings
                                        .where(status: [:accepted, :pending])
                                        .where.not(id: exclude_booking_id)
                                        .where.not(scheduled_at: nil)
      
      # Build a hash of conflicting time ranges
      conflicting_ranges = conflicting_bookings.map do |booking|
        start_time = booking.scheduled_at
        end_time = start_time + (booking.professional_service.duration_minutes || 60).minutes
        { start: start_time, end: end_time }
      end
      
      # Calculate the first and last day of the month
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      
      available_slots = {}
      
      # Iterate through each day of the month
      (start_date..end_date).each do |date|
        # Convert Ruby wday (Sunday=0) to our system (Monday=0, Sunday=6)
        # Ruby: Sunday=0, Monday=1, ..., Saturday=6
        # Our system: Monday=0, Tuesday=1, ..., Sunday=6
        day_of_week = date.wday == 0 ? 6 : date.wday - 1
        
        # Find availabilities for this day of week
        day_availabilities = professional_availabilities.select { |a| a.day_of_week == day_of_week }
        
        next if day_availabilities.empty?
        
        slots_for_day = []
        
        day_availabilities.each do |availability|
          # Convert availability times to datetime for this specific date
          availability_start = Time.zone.parse("#{date} #{availability.start_time.strftime('%H:%M')}")
          availability_end = Time.zone.parse("#{date} #{availability.end_time.strftime('%H:%M')}")
          
          # Skip if availability window is invalid
          next if availability_end <= availability_start
          
          # Calculate available duration in minutes
          available_duration_minutes = ((availability_end - availability_start) / 60).to_i
          
          # Skip if availability window is too small for the service duration
          next if available_duration_minutes < duration_minutes
          
          # Generate time slots within this availability window
          current_slot_start = availability_start
          
          while current_slot_start + duration_minutes.minutes <= availability_end
            slot_end = current_slot_start + duration_minutes.minutes
            
            # Check if this slot conflicts with existing bookings
            slot_conflicts = conflicting_ranges.any? do |conflict|
              # Check for overlap: slot starts before conflict ends AND slot ends after conflict starts
              current_slot_start < conflict[:end] && slot_end > conflict[:start]
            end
            
            unless slot_conflicts
              slots_for_day << {
                start: current_slot_start,
                end: slot_end,
                formatted: current_slot_start.strftime('%H:%M')
              }
            end
            
            # Move to next slot (30-minute increments for better UX)
            current_slot_start += 30.minutes
          end
        end
        
        # Add the date to available_slots if there are any slots, even if empty (to show the day is available)
        if slots_for_day.any?
          available_slots[date] = slots_for_day.sort_by { |s| s[:start] }
        end
      end
      
      available_slots
    end
  end
end
