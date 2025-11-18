class Client::DashboardController < Client::BaseController

  def index
    # Count upcoming bookings (with scheduled_at in the future)
    @upcoming_bookings_count = current_user.client_bookings
                                            .where("scheduled_at > ?", Time.current)
                                            .count
    
    # Count vehicles
    @vehicles_count = current_user.vehicles.count
    
    # Count completed services (accepted bookings with scheduled_at in the past)
    @completed_services_count = current_user.client_bookings
                                            .where(status: :accepted)
                                            .where("scheduled_at < ?", Time.current)
                                            .count
    
    # Count urgent reminders (status_color == 'red', which means <= 15 days)
    all_reminders = Reminder.for_user(current_user).not_done.includes(:vehicle)
    @urgent_reminders_count = all_reminders.count { |r| r.status_color == 'red' }
    
    # Get last 3 upcoming bookings (pending or accepted, ordered by scheduled_at)
    @upcoming_bookings = current_user.client_bookings
                                     .where("scheduled_at > ?", Time.current)
                                     .where(status: [:pending, :accepted])
                                     .includes(:professional, :vehicle, :professional_service)
                                     .order(scheduled_at: :asc)
                                     .limit(3)
    
    # Get user vehicles
    @vehicles = current_user.vehicles.order(created_at: :desc).limit(5)
    
    # Get urgent reminders (red status, <= 15 days)
    @urgent_reminders = all_reminders.select { |r| r.status_color == 'red' }
                                     .sort_by(&:due_date)
                                     .first(3)
  end

end
