require 'ostruct'

class Client::BookingsController < Client::BaseController
  before_action :set_booking, only: [:show, :edit, :update, :cancel]
  before_action :set_vehicles, only: [:new, :edit]
  before_action :set_professionals, only: [:new, :edit]

  def index
    # Dummy data based on Bookings table from data_model.md
    @bookings = [
      # Completed bookings with reviews (3)
      OpenStruct.new(
        id: 1,
        service_type: 'Révision complète',
        professional_name: 'ProMeca_Paris15',
        vehicle_model: 'Peugeot 208',
        scheduled_at: DateTime.current - 30.days,
        status: 'completed',
        price: 180.00,
        travel_fee: 15.00,
        description: 'Révision des 30000 km avec changement filtres',
        reviewed?: true,
        review_rating: 5,
        review_comment: 'Service excellent ! Très professionnel et rapide. Je recommande vivement.'
      ),
      OpenStruct.new(
        id: 2,
        service_type: 'Lavage intérieur/extérieur',
        professional_name: 'DetailPro_Paris16',
        vehicle_model: 'Renault Clio',
        scheduled_at: DateTime.current - 20.days,
        status: 'completed',
        price: 65.00,
        travel_fee: 0,
        description: 'Lavage complet avec cirage',
        reviewed?: true,
        review_rating: 5,
        review_comment: 'Ma voiture est comme neuve ! Travail impeccable, très satisfait du résultat.'
      ),
      OpenStruct.new(
        id: 3,
        service_type: 'Changement pneus',
        professional_name: 'ProMeca_Paris14',
        vehicle_model: 'Citroën C3',
        scheduled_at: DateTime.current - 15.days,
        status: 'completed',
        price: 320.00,
        travel_fee: 10.00,
        description: 'Montage 4 pneus été avec équilibrage',
        reviewed?: true,
        review_rating: 4,
        review_comment: 'Bon service, prix correct. Petit délai d\'attente mais travail bien fait.'
      ),
      # Completed bookings WITHOUT reviews - showing "Laisser un avis" button (2)
      OpenStruct.new(
        id: 4,
        service_type: 'Réparation carrosserie',
        professional_name: 'CarrossPro_Paris18',
        vehicle_model: 'Volkswagen Golf',
        scheduled_at: DateTime.current - 7.days,
        status: 'completed',
        price: 450.00,
        travel_fee: 20.00,
        description: 'Réparation rayure portière arrière',
        reviewed?: false
      ),
      OpenStruct.new(
        id: 5,
        service_type: 'Diagnostic électronique',
        professional_name: 'ProMeca_Paris13',
        vehicle_model: 'Peugeot 3008',
        scheduled_at: DateTime.current - 3.days,
        status: 'completed',
        price: 75.00,
        travel_fee: 15.00,
        description: 'Diagnostic voyant moteur',
        reviewed?: false
      ),
      # Bookings in other statuses (5)
      OpenStruct.new(
        id: 6,
        service_type: 'Entretien annuel',
        professional_name: 'ProMeca_Paris15',
        vehicle_model: 'Renault Captur',
        scheduled_at: DateTime.current + 3.days,
        status: 'confirmed',
        price: 150.00,
        travel_fee: 15.00,
        description: 'Révision annuelle complète',
        reviewed?: false
      ),
      OpenStruct.new(
        id: 7,
        service_type: 'Vidange',
        professional_name: 'ProMeca_Paris10',
        vehicle_model: 'Peugeot 208',
        scheduled_at: DateTime.current + 7.days,
        status: 'confirmed',
        price: 85.00,
        travel_fee: 0,
        description: 'Vidange moteur diesel',
        reviewed?: false
      ),
      OpenStruct.new(
        id: 8,
        service_type: 'Lavage premium',
        professional_name: 'DetailPro_Paris11',
        vehicle_model: 'BMW Série 3',
        scheduled_at: DateTime.current + 2.days,
        status: 'pending',
        price: 95.00,
        travel_fee: 0,
        description: 'Lavage premium + protection céramique',
        reviewed?: false
      ),
      OpenStruct.new(
        id: 9,
        service_type: 'Changement plaquettes',
        professional_name: 'ProMeca_Paris19',
        vehicle_model: 'Citroën C3',
        scheduled_at: DateTime.current + 5.days,
        status: 'pending',
        price: 180.00,
        travel_fee: 10.00,
        description: 'Remplacement plaquettes freins avant',
        reviewed?: false
      ),
      OpenStruct.new(
        id: 10,
        service_type: 'Peinture pare-choc',
        professional_name: 'CarrossPro_Paris17',
        vehicle_model: 'Renault Clio',
        scheduled_at: DateTime.current - 2.days,
        status: 'cancelled',
        price: nil,
        travel_fee: nil,
        description: 'Demande annulée par le client',
        reviewed?: false
      )
    ]
  end

  def show
    # @booking is set by before_action
  end

  def new
    @booking = OpenStruct.new
  end

  def edit
    # @booking is set by before_action
  end

  def create
    # In production, this would save to database
    redirect_to client_bookings_path, notice: 'Demande de réservation envoyée avec succès.'
  end

  def update
    # In production, this would update database
    redirect_to client_booking_path(params[:id]), notice: 'Réservation mise à jour avec succès.'
  end

  def cancel
    # In production, this would cancel the booking
    redirect_to client_bookings_path, notice: 'Réservation annulée avec succès.'
  end

  private

  def set_booking
    # Dummy booking for show/edit/cancel
    @booking = OpenStruct.new(
      id: params[:id].to_i,
      service_type: 'Entretien annuel',
      professional_name: 'AutoPro Garage',
      professional_id: 1,
      vehicle_model: 'Peugeot 208',
      vehicle_id: 1,
      scheduled_at: DateTime.current + 2.days,
      status: 'confirmed',
      price: 120.00,
      travel_fee: 15.00,
      description: 'Entretien complet avec vidange',
      current_mileage: 45000,
      reviewed?: false,
      paid?: false
    )
  end

  def set_vehicles
    @vehicles = [
      OpenStruct.new(id: 1, make: 'Peugeot', model: '208', year: 2020),
      OpenStruct.new(id: 2, make: 'Renault', model: 'Clio', year: 2019),
      OpenStruct.new(id: 3, make: 'Citroën', model: 'C3', year: 2021)
    ]
  end

  def set_professionals
    @professionals = [
      OpenStruct.new(id: 1, company_name: 'AutoPro Garage'),
      OpenStruct.new(id: 2, company_name: 'Méca Express'),
      OpenStruct.new(id: 3, company_name: 'Clean Car Pro')
    ]
  end
end
