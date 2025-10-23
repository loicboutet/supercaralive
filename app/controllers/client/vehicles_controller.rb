require 'ostruct'

class Client::VehiclesController < Client::BaseController
  before_action :set_vehicle, only: [:edit, :update, :destroy]

  def index
    # Dummy data based on Vehicles table from data_model.md
    @vehicles = [
      OpenStruct.new(
        id: 1,
        make: 'Peugeot',
        model: '208',
        year: 2020,
        mileage: 45000,
        vin: '1HGBH41JXMN109186',
        license_plate: 'AB-123-CD',
        notes: 'Entretien régulier'
      ),
      OpenStruct.new(
        id: 2,
        make: 'Renault',
        model: 'Clio',
        year: 2019,
        mileage: 62000,
        vin: 'WBADT43452G123456',
        license_plate: 'EF-456-GH',
        notes: nil
      ),
      OpenStruct.new(
        id: 3,
        make: 'Citroën',
        model: 'C3',
        year: 2021,
        mileage: 28000,
        vin: nil,
        license_plate: 'IJ-789-KL',
        notes: 'Véhicule de société'
      )
    ]
  end

  def new
    @vehicle = OpenStruct.new
  end

  def edit
    # @vehicle is set by before_action
  end

  def create
    # In production, this would save to database
    redirect_to client_vehicles_path, notice: 'Véhicule ajouté avec succès.'
  end

  def update
    # In production, this would update database
    redirect_to client_vehicles_path, notice: 'Véhicule mis à jour avec succès.'
  end

  def destroy
    # In production, this would delete from database
    redirect_to client_vehicles_path, notice: 'Véhicule supprimé avec succès.'
  end

  private

  def set_vehicle
    # Dummy vehicle for edit/update/destroy
    @vehicle = OpenStruct.new(
      id: params[:id].to_i,
      make: 'Peugeot',
      model: '208',
      year: 2020,
      mileage: 45000,
      vin: '1HGBH41JXMN109186',
      license_plate: 'AB-123-CD',
      notes: 'Entretien régulier'
    )
  end
end
