class Admin::BookingsController < ApplicationController
  layout 'admin'
  before_action :require_admin

  # GET /admin/bookings
  def index
    @bookings = Booking.includes(:client, :professional, :professional_service)
    
    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      conditions = []
      values = []
      
      # Search in clients
      client_ids = User.where(
        "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(email) LIKE ?",
        search_term, search_term, search_term
      ).pluck(:id)
      if client_ids.any?
        conditions << "client_id IN (?)"
        values << client_ids
      end
      
      # Search in professionals
      professional_ids = User.where(
        "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(company_name) LIKE ?",
        search_term, search_term, search_term, search_term
      ).pluck(:id)
      if professional_ids.any?
        conditions << "professional_id IN (?)"
        values << professional_ids
      end
      
      # Search in services
      service_ids = ProfessionalService.where("LOWER(name) LIKE ?", search_term).pluck(:id)
      if service_ids.any?
        conditions << "professional_service_id IN (?)"
        values << service_ids
      end
      
      if conditions.any?
        @bookings = @bookings.where(conditions.join(" OR "), *values)
      else
        # No matches found, return empty result
        @bookings = @bookings.none
      end
    end
    
    # Apply status filter
    if params[:status].present? && params[:status] != "all"
      @bookings = @bookings.where(status: params[:status])
    end
    
    # Apply period filter
    if params[:period].present? && params[:period] != "all"
      case params[:period]
      when "today"
        @bookings = @bookings.where("DATE(scheduled_at) = ?", Date.current)
      when "this_week"
        @bookings = @bookings.where("scheduled_at >= ?", Date.current.beginning_of_week)
      when "this_month"
        @bookings = @bookings.where("scheduled_at >= ?", Date.current.beginning_of_month)
      end
    end
    
    # Apply client filter
    if params[:client_id].present?
      @bookings = @bookings.where(client_id: params[:client_id])
      @filtered_client = User.find_by(id: params[:client_id])
    end
    
    # Calculate statistics
    @total_bookings = Booking.count
    @pending_bookings = Booking.where(status: :pending).count
    @accepted_bookings = Booking.where(status: :accepted).count
    
    # Bookings with scheduled_at in the current month that are past
    current_month_start = Date.current.beginning_of_month
    current_month_end = Date.current.end_of_month
    @past_month_bookings = Booking.where(
      "scheduled_at >= ? AND scheduled_at <= ? AND scheduled_at < ?",
      current_month_start.beginning_of_day,
      current_month_end.end_of_day,
      Time.current
    ).count
    
    # Order and paginate
    @bookings = @bookings.order(created_at: :desc)
    @pagy, @bookings = pagy(@bookings, items: 20)
  end

  # GET /admin/bookings/:id
  def show
    @booking = Booking.includes(:client, :professional, :professional_service, :vehicle, professional_service: :services)
                      .find(params[:id])
  end
end
