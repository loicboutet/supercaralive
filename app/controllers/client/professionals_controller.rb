class Client::ProfessionalsController < Client::BaseController
  include Pagy::Backend

  def index
    # Base query: only active professionals
    @professionals = User.where(role: "Professional", status: "active")
    
    # Filter by service category (type de service)
    if params[:service_category].present? && params[:service_category] != "all"
      @professionals = @professionals.joins(professional_services: :services)
                                     .where(professional_services: { active: true })
                                     .where(services: { category: params[:service_category], active: true })
                                     .distinct
    end
    
    # Filter by location (flexible matching)
    if params[:location].present?
      location_term = params[:location].strip.downcase
      @professionals = @professionals.where(
        "LOWER(location) LIKE ? OR LOWER(intervention_zone) LIKE ?",
        "%#{location_term}%", "%#{location_term}%"
      )
    end
    
    # Filter by radius (km) - extract number from intervention_zone
    if params[:radius_km].present?
      radius_value = params[:radius_km].to_i
      if radius_value > 0
        # This is a simplified filter - in a real app you'd use geolocation
        # For now, we'll just filter by intervention_zone containing the number
        # Note: This is not a true radius filter, but works with the string field
        @professionals = @professionals.where("intervention_zone LIKE ?", "%#{radius_value}%")
      end
    end
    
    # Order by created_at (most recent first)
    @professionals = @professionals.order(created_at: :desc)
    
    # Paginate
    @pagy, @professionals = pagy(@professionals, items: 12)
    
    # Get available service categories for filter dropdown
    @service_categories = Service.active.distinct.pluck(:category).sort
  end

  def show
    @professional = User.includes(:specialties).find_by(id: params[:id], role: "Professional")
    
    unless @professional&.active?
      redirect_to client_professionals_path, alert: "Ce professionnel n'est pas disponible."
      return
    end
    
    # Get active professional services
    @professional_services = @professional.professional_services.active.includes(:services).order(created_at: :desc)
  end

  def availability
    # TODO: Implement availability
  end
end
