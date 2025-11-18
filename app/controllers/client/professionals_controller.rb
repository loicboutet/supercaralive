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
    
    # Filter by location and radius (geographic search)
    use_geographic_search = false
    if params[:location].present? && params[:radius_km].present?
      location_term = params[:location].strip
      radius_value = params[:radius_km].to_i
      
      if radius_value > 0
        # Geocode the search location
        search_coordinates = Geocoder.coordinates(location_term)
        
        if search_coordinates.present?
          search_lat, search_lon = search_coordinates
          # Find professionals within the radius using geocoder's near method
          # We need to ensure professionals have coordinates before filtering
          # Note: .near() automatically orders by distance
          @professionals = @professionals.where.not(latitude: nil, longitude: nil)
                                         .near([search_lat, search_lon], radius_value, units: :km)
          use_geographic_search = true
        else
          # If geocoding fails, fall back to text search
          location_term_downcase = location_term.downcase
          @professionals = @professionals.where(
            "LOWER(location) LIKE ? OR LOWER(intervention_zone) LIKE ?",
            "%#{location_term_downcase}%", "%#{location_term_downcase}%"
          )
        end
      else
        # If radius is 0 or invalid, use text search
        location_term_downcase = location_term.downcase
        @professionals = @professionals.where(
          "LOWER(location) LIKE ? OR LOWER(intervention_zone) LIKE ?",
          "%#{location_term_downcase}%", "%#{location_term_downcase}%"
        )
      end
    elsif params[:location].present?
      # If only location is provided (without radius), use text search
      location_term = params[:location].strip.downcase
      @professionals = @professionals.where(
        "LOWER(location) LIKE ? OR LOWER(intervention_zone) LIKE ?",
        "%#{location_term}%", "%#{location_term}%"
      )
    end
    
    # Order by distance (for geographic search) or created_at (for text search)
    unless use_geographic_search
      @professionals = @professionals.order(created_at: :desc)
    end
    
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
