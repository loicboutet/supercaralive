class Client::BookingsController < Client::BaseController
  include Pagy::Backend
  
  before_action :set_booking, only: [:show, :edit, :update, :cancel]
  before_action :set_vehicles, only: [:new, :edit]
  before_action :set_professionals, only: [:new, :edit]
  before_action :set_professional_services, only: [:new, :edit]

  def index
    @bookings = current_user.client_bookings.includes(:professional, :vehicle, :professional_service)
                            .order(created_at: :desc)
    
    # Filter by status
    if params[:status].present?
      @bookings = @bookings.where(status: params[:status])
    end
    
    # Paginate
    @pagy, @bookings = pagy(@bookings, items: 10)
  end

  def show
    # @booking is set by before_action
  end

  def new
    @booking = Booking.new
    @booking.client_id = current_user.id
    
    # If professional_id is passed, pre-select it
    if params[:professional_id].present?
      @booking.professional_id = params[:professional_id]
      @pre_selected_professional = User.find_by(id: params[:professional_id])
      @show_professional_field = false
      set_professional_services
    else
      @show_professional_field = true
      # If a professional is selected via form, load their services
      if params[:booking] && params[:booking][:professional_id].present?
        @booking.professional_id = params[:booking][:professional_id]
        set_professional_services
      end
    end
  end

  def edit
    # @booking is set by before_action
    @show_professional_field = false # Can't change professional when editing
    set_professional_services
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.client_id = current_user.id
    @booking.status = :pending
    
    if @booking.save
      respond_to do |format|
        format.html { redirect_to client_bookings_path, notice: 'Demande de réservation envoyée avec succès.' }
      end
    else
      @show_professional_field = params[:professional_id].blank?
      set_vehicles
      set_professionals
      set_professional_services
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @booking.update(booking_params)
      respond_to do |format|
        format.html { redirect_to client_booking_path(@booking), notice: 'Réservation mise à jour avec succès.' }
      end
    else
      set_vehicles
      set_professionals
      set_professional_services
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    if @booking.update(status: :cancelled)
      respond_to do |format|
        format.html { redirect_to client_bookings_path, notice: 'Réservation annulée avec succès.' }
      end
    else
      redirect_to client_bookings_path, alert: 'Impossible d\'annuler la réservation.'
    end
  end

  def available_slots
    professional_id = params[:professional_id].present? ? params[:professional_id].to_i : (@booking&.professional_id)
    professional_service_id = params[:professional_service_id].present? ? params[:professional_service_id].to_i : (@booking&.professional_service_id)
    month = params[:month]&.to_i || Date.current.month
    year = params[:year]&.to_i || Date.current.year
    exclude_booking_id = params[:exclude_booking_id]&.to_i || @booking&.id

    if professional_id.nil? || professional_id == 0 || professional_service_id.nil? || professional_service_id == 0
      render json: { error: 'Professional and service are required' }, status: :bad_request
      return
    end

    professional = User.find_by(id: professional_id)
    professional_service = ProfessionalService.find_by(id: professional_service_id)

    unless professional&.professional?
      render json: { error: 'Invalid professional' }, status: :bad_request
      return
    end

    unless professional_service&.user_id == professional_id
      render json: { error: 'Service does not belong to this professional' }, status: :bad_request
      return
    end

    slots = professional.available_time_slots_for_service(
      professional_service,
      month: month,
      year: year,
      exclude_booking_id: exclude_booking_id
    )

    # Format slots for JSON response
    formatted_slots = slots.map do |date, time_slots|
      [
        date.to_s,
        time_slots.map do |slot|
          {
            start: slot[:start].iso8601,
            end: slot[:end].iso8601,
            formatted: slot[:formatted]
          }
        end
      ]
    end.to_h

    render json: { slots: formatted_slots }
  end

  private

  def set_booking
    @booking = current_user.client_bookings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to client_bookings_path, alert: 'Réservation introuvable.'
  end

  def set_vehicles
    @vehicles = current_user.vehicles.order(created_at: :desc)
  end

  def set_professionals
    # Only show professionals with whom the client has already worked (has at least one booking)
    professional_ids = current_user.client_bookings.select(:professional_id).distinct.pluck(:professional_id)
    @professionals = User.where(id: professional_ids, role: "Professional").order(:company_name)
  end

  def set_professional_services
    professional_id = @booking&.professional_id || params[:professional_id] || (params[:booking] && params[:booking][:professional_id])
    
    if professional_id.present?
      professional = User.find_by(id: professional_id)
      @professional_services = professional&.professional_services&.active&.order(:name) || []
    else
      @professional_services = []
    end
  end

  def booking_params
    params.require(:booking).permit(:professional_id, :vehicle_id, :professional_service_id, :scheduled_at, :current_mileage, :description)
  end
end
