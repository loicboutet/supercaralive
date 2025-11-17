class Client::VehiclesController < Client::BaseController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @vehicles = pagy(current_user.vehicles.order(created_at: :desc), items: 10)
  end

  def show
    # @vehicle is set by before_action
  end

  def new
    @vehicle = current_user.vehicles.build
  end

  def edit
    # @vehicle is set by before_action
  end

  def create
    @vehicle = current_user.vehicles.build(vehicle_params)

    if @vehicle.save
      respond_to do |format|
        format.html { redirect_to client_vehicles_path, notice: 'Véhicule ajouté avec succès.' }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @vehicle.update(vehicle_params)
      respond_to do |format|
        format.html { redirect_to client_vehicle_path(@vehicle), notice: 'Véhicule mis à jour avec succès.' }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @vehicle.destroy
    respond_to do |format|
      format.html { redirect_to client_vehicles_path, notice: 'Véhicule supprimé avec succès.' }
    end
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(
      :brand, :model, :year, :mileage, :vin_number,
      :next_maintenance_date, :next_technical_inspection_date,
      :upcoming_service, :maintenance_reminders_enabled
    )
  end
end
