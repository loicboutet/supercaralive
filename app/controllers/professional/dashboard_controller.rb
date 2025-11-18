class Professional::DashboardController < Professional::BaseController
  def index
    # Count pending bookings
    @pending_bookings_count = current_user.professional_bookings.where(status: :pending).count
    
    # Count upcoming accepted bookings (accepted status with scheduled_at in the future)
    @upcoming_bookings_count = current_user.professional_bookings
                                            .where(status: :accepted)
                                            .where("scheduled_at > ?", Time.current)
                                            .count
    
    # Get last 3 pending bookings
    @pending_bookings = current_user.professional_bookings
                                    .where(status: :pending)
                                    .includes(:client, :vehicle, :professional_service)
                                    .order(created_at: :desc)
                                    .limit(3)
    
    # Get last 4 accepted bookings (upcoming)
    @upcoming_confirmed_bookings = current_user.professional_bookings
                                               .where(status: :accepted)
                                               .where("scheduled_at > ?", Time.current)
                                               .includes(:client, :vehicle, :professional_service)
                                               .order(scheduled_at: :asc)
                                               .limit(4)
  end
end
