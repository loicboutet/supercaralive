class Professional::AvailabilitySlotsController < Professional::BaseController
  before_action :set_availability, only: [:edit, :update, :destroy]
  before_action :ensure_availability_owner, only: [:edit, :update, :destroy]

  def index
    # Group availabilities by day of week
    @availabilities_by_day = current_user.availabilities
                                         .ordered_by_day
                                         .group_by(&:day_of_week)
    
    # Initialize hash for all days (0-6 for Monday-Sunday)
    @days = {}
    (0..6).each do |day|
      @days[day] = {
        name: day_name(day),
        availabilities: @availabilities_by_day[day] || []
      }
    end
  end

  def calendar
    # Get month and year from params or use current month
    @month = params[:month]&.to_i || Date.current.month
    @year = params[:year]&.to_i || Date.current.year
    
    # Validate month and year
    @month = 1 if @month < 1 || @month > 12
    @year = Date.current.year if @year < 2000 || @year > 2100
    
    # Calculate date range for the month
    @start_date = Date.new(@year, @month, 1)
    @end_date = @start_date.end_of_month
    @current_date = Date.current
    
    # Load availabilities grouped by day of week
    @availabilities_by_day = current_user.availabilities.ordered_by_day.group_by(&:day_of_week)
    
    # Load custom availabilities for this month (these override regular availabilities for specific dates)
    @custom_availabilities_by_date = current_user.custom_availabilities
                                                  .for_date_range(@start_date, @end_date)
                                                  .order(:date, :start_time)
                                                  .group_by(&:date)
    
    # Load bookings for this month
    @bookings = current_user.professional_bookings
                            .where(scheduled_at: @start_date.beginning_of_day..@end_date.end_of_day)
                            .includes(:client, :vehicle, :professional_service)
    
    # Group bookings by date
    @bookings_by_date = @bookings.group_by { |b| b.scheduled_at.to_date }
    
    # Calculate statistics
    calculate_statistics
  end

  def day_details
    date = Date.parse(params[:date])
    
    # Get day of week (0 = Monday, 6 = Sunday)
    day_of_week = date.wday == 0 ? 6 : date.wday - 1
    
    # Get custom availabilities for this specific date (these override regular availabilities)
    custom_availabilities = current_user.custom_availabilities.for_date(date).ordered_by_time
    
    # Get availabilities for this day of week (only if no custom availabilities exist)
    availabilities = if custom_availabilities.any?
      [] # Custom availabilities override regular ones
    else
      current_user.availabilities.for_day(day_of_week).ordered_by_day
    end
    
    # Get bookings for this date
    bookings = current_user.professional_bookings
                            .where(scheduled_at: date.beginning_of_day..date.end_of_day)
                            .includes(:client, :vehicle, :professional_service)
                            .order(:scheduled_at)
    
    render partial: 'day_details', locals: { 
      date: date, 
      availabilities: availabilities, 
      custom_availabilities: custom_availabilities,
      bookings: bookings 
    }
  end

  def new
    @availability = current_user.availabilities.build
    @day_of_week = params[:day_of_week]&.to_i
  end

  def create
    @availability = current_user.availabilities.build(availability_params)

    if @availability.save
      respond_to do |format|
        format.html { redirect_to professional_availability_slots_path, notice: "Disponibilité créée avec succès." }
        format.json { render json: { status: "success", message: "Disponibilité créée avec succès.", availability: @availability } }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:alert] = @availability.errors.full_messages.join(", ")
          redirect_to professional_availability_slots_path
        }
        format.json { render json: { status: "error", errors: @availability.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @availability.update(availability_params)
      respond_to do |format|
        format.html { redirect_to professional_availability_slots_path, notice: "Disponibilité mise à jour avec succès." }
        format.json { render json: { status: "success", message: "Disponibilité mise à jour avec succès.", availability: @availability } }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:alert] = @availability.errors.full_messages.join(", ")
          redirect_to professional_availability_slots_path
        }
        format.json { render json: { status: "error", errors: @availability.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @availability.destroy
    respond_to do |format|
      format.html { redirect_to professional_availability_slots_path, notice: "Disponibilité supprimée avec succès." }
      format.json { head :no_content }
    end
  end

  private

  def set_availability
    @availability = Availability.find(params[:id])
  end

  def ensure_availability_owner
    unless @availability.user == current_user
      redirect_to professional_availability_slots_path, alert: "Vous n'avez pas accès à cette disponibilité."
    end
  end

  def availability_params
    params.require(:availability).permit(:day_of_week, :start_time, :end_time)
  end

  def day_name(day)
    case day
    when 0 then "Lundi"
    when 1 then "Mardi"
    when 2 then "Mercredi"
    when 3 then "Jeudi"
    when 4 then "Vendredi"
    when 5 then "Samedi"
    when 6 then "Dimanche"
    else "Jour inconnu"
    end
  end

  def calculate_statistics
    # Count available slots (based on availabilities for days in the month)
    @available_slots_count = 0
    (@start_date..@end_date).each do |date|
      day_of_week = date.wday == 0 ? 6 : date.wday - 1 # Convert to Monday=0 format
      @available_slots_count += (@availabilities_by_day[day_of_week] || []).count
    end
    
    # Count total bookings
    @total_bookings_count = @bookings.count
    
    # Count accepted bookings (validated)
    @accepted_bookings_count = @bookings.where(status: :accepted).count
    
    # Calculate occupancy rate
    if @available_slots_count > 0
      @occupancy_rate = ((@accepted_bookings_count.to_f / @available_slots_count) * 100).round
    else
      @occupancy_rate = 0
    end
    
    # Count days with validated bookings (accepted)
    @worked_days_count = @bookings.where(status: :accepted)
                                  .pluck(:scheduled_at)
                                  .map(&:to_date)
                                  .uniq
                                  .count
  end
end
