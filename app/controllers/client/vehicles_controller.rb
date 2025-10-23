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
      ),
      OpenStruct.new(
        id: 4,
        make: 'BMW',
        model: 'Série 3',
        year: 2022,
        mileage: 15000,
        vin: '5UXWX7C5XBA123789',
        license_plate: 'MN-234-OP',
        notes: 'Garantie constructeur'
      ),
      OpenStruct.new(
        id: 5,
        make: 'Audi',
        model: 'A4',
        year: 2018,
        mileage: 85000,
        vin: 'WAUZZZ8K8DA456123',
        license_plate: 'QR-567-ST',
        notes: nil
      ),
      OpenStruct.new(
        id: 6,
        make: 'Mercedes',
        model: 'Classe A',
        year: 2020,
        mileage: 52000,
        vin: 'WDD1760081N789456',
        license_plate: 'UV-890-WX',
        notes: 'Véhicule électrique'
      ),
      OpenStruct.new(
        id: 7,
        make: 'Volkswagen',
        model: 'Golf',
        year: 2019,
        mileage: 68000,
        vin: 'WVWZZZ1KZBW321654',
        license_plate: 'YZ-123-AB',
        notes: 'Révision effectuée'
      ),
      OpenStruct.new(
        id: 8,
        make: 'Toyota',
        model: 'Yaris',
        year: 2021,
        mileage: 32000,
        vin: 'VNKKH1H31JA987321',
        license_plate: 'CD-456-EF',
        notes: 'Hybride'
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
