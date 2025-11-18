class Professional::ProfessionalServicesController < Professional::BaseController
  before_action :set_professional_service, only: [:edit, :update, :destroy, :toggle_active]
  before_action :ensure_professional_service_owner, only: [:edit, :update, :destroy, :toggle_active]

  # GET /professional/professional_services
  def index
    @professional_services = current_user.professional_services.order(created_at: :desc)

    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @professional_services = @professional_services.where("LOWER(name) LIKE ?", search_term)
    end

    # Apply status filter
    if params[:status].present? && params[:status] != "all"
      case params[:status]
      when "active"
        @professional_services = @professional_services.active
      when "inactive"
        @professional_services = @professional_services.inactive
      end
    end

    # Calculate statistics
    all_services = current_user.professional_services
    @active_count = all_services.active.count
    @inactive_count = all_services.inactive.count
    @total_bookings = 0 # Placeholder - will be implemented later
    
    # Calculate average flat rate (excluding travel pricing)
    flat_rate_services = all_services.flat_rate.where.not(flat_rate_price: nil)
    @average_flat_rate = flat_rate_services.any? ? flat_rate_services.average(:flat_rate_price).to_f.round(2) : 0
    
    # Calculate average hourly rate (excluding travel pricing)
    hourly_rate_services = all_services.hourly_rate.where.not(hourly_rate_price: nil)
    @average_hourly_rate = hourly_rate_services.any? ? hourly_rate_services.average(:hourly_rate_price).to_f.round(2) : 0

    # Get top 3 most popular professional services (by booking count)
    @popular_services = current_user.professional_services
                                    .left_joins(:bookings)
                                    .group('professional_services.id')
                                    .select('professional_services.*, COUNT(bookings.id) as bookings_count')
                                    .order('COUNT(bookings.id) DESC')
                                    .having('COUNT(bookings.id) > 0')
                                    .limit(3)

    # Order and paginate
    @pagy, @professional_services = pagy(@professional_services, items: 10)
  end

  # GET /professional/professional_services/new
  def new
    @professional_service = current_user.professional_services.build
    @available_services = Service.active.order(:name)
  end

  # GET /professional/professional_services/:id/edit
  def edit
    @available_services = Service.active.order(:name)
  end

  # POST /professional/professional_services
  def create
    @professional_service = current_user.professional_services.build(professional_service_params)

    if @professional_service.save
      respond_to do |format|
        format.html { redirect_to professional_professional_services_path, notice: "Service créé avec succès." }
        format.json { render json: { status: "success", message: "Service créé avec succès." } }
      end
    else
      @available_services = Service.active.order(:name)
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @professional_service.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /professional/professional_services/:id
  def update
    if @professional_service.update(professional_service_params)
      respond_to do |format|
        format.html { redirect_to professional_professional_services_path, notice: "Service mis à jour avec succès." }
        format.json { render json: { status: "success", message: "Service mis à jour avec succès." } }
      end
    else
      @available_services = Service.active.order(:name)
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @professional_service.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /professional/professional_services/:id
  def destroy
    @professional_service.destroy
    respond_to do |format|
      format.html { redirect_to professional_professional_services_path, notice: "Service supprimé avec succès." }
      format.json { render json: { status: "success", message: "Service supprimé avec succès." } }
    end
  end

  # PATCH /professional/professional_services/:id/toggle_active
  def toggle_active
    @professional_service.toggle_active!
    respond_to do |format|
      format.html { redirect_to professional_professional_services_path, notice: "Statut du service mis à jour avec succès." }
      format.json { render json: { status: "success", message: "Statut du service mis à jour avec succès.", active: @professional_service.active } }
    end
  end

  private

  def set_professional_service
    @professional_service = ProfessionalService.find(params[:id])
  end

  def ensure_professional_service_owner
    unless @professional_service.user == current_user
      redirect_to professional_professional_services_path, alert: "Vous n'avez pas accès à ce service."
    end
  end

  def professional_service_params
    params.require(:professional_service).permit(
      :name, 
      :price, 
      :duration_minutes, 
      :active,
      :pricing_type,
      :flat_rate_price,
      :hourly_rate_price,
      :travel_pricing_type,
      :travel_flat_rate,
      :travel_per_km_rate,
      service_ids: []
    )
  end
end
