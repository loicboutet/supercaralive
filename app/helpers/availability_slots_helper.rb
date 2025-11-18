module AvailabilitySlotsHelper
  def format_time(time)
    time.strftime('%Hh%M')
  end
  
  def format_time_range(start_time, end_time)
    "#{format_time(start_time)} - #{format_time(end_time)}"
  end
  
  def format_duration(minutes)
    hours = minutes / 60
    mins = minutes % 60
    if hours > 0 && mins > 0
      "#{hours}h#{mins.to_s.rjust(2, '0')}"
    elsif hours > 0
      "#{hours}h"
    else
      "#{mins}min"
    end
  end
end

