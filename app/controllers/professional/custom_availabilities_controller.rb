class Professional::CustomAvailabilitiesController < Professional::BaseController
  before_action :set_custom_availability, only: [:destroy]

  def create
    # Accept multiple custom availabilities for the same date
    date = Date.parse(params[:date])
    user_id = current_user.id
    
    # Delete existing custom availabilities for this date
    current_user.custom_availabilities.for_date(date).destroy_all
    
    # Create new custom availabilities from params
    custom_availabilities = []
    errors = []
    
    if params[:custom_availabilities].present?
      params[:custom_availabilities].each do |ca_params|
        custom_availability = current_user.custom_availabilities.build(
          date: date,
          start_time: ca_params[:start_time],
          end_time: ca_params[:end_time]
        )
        
        if custom_availability.save
          custom_availabilities << custom_availability
        else
          errors.concat(custom_availability.errors.full_messages)
        end
      end
    end
    
    if errors.any?
      respond_to do |format|
        format.html { 
          flash[:alert] = errors.join(", ")
          redirect_to calendar_professional_availability_slots_path(month: date.month, year: date.year)
        }
        format.json { render json: { status: "error", errors: errors }, status: :unprocessable_entity }
      end
    else
      respond_to do |format|
        format.html { 
          redirect_to calendar_professional_availability_slots_path(month: date.month, year: date.year), 
                      notice: "Disponibilités personnalisées créées avec succès." 
        }
        format.json { render json: { status: "success", message: "Disponibilités personnalisées créées avec succès.", custom_availabilities: custom_availabilities } }
      end
    end
  end

  def destroy
    date = @custom_availability.date
    @custom_availability.destroy
    
    respond_to do |format|
      format.html { 
        redirect_to calendar_professional_availability_slots_path(month: date.month, year: date.year), 
                    notice: "Disponibilité personnalisée supprimée avec succès." 
      }
      format.json { head :no_content }
    end
  end

  private

  def set_custom_availability
    @custom_availability = current_user.custom_availabilities.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to calendar_professional_availability_slots_path, alert: "Disponibilité personnalisée introuvable."
  end
end

