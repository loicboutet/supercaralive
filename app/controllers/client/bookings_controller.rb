require 'ostruct'

class Client::BookingsController < Client::BaseController
  before_action :set_booking, only: [:show, :edit, :update, :cancel]
  before_action :set_vehicles, only: [:new, :edit]
  before_action :set_professionals, only: [:new, :edit]

  def index
    # Dummy data based on Bookings table from data_model.md
    @bookings = [
      OpenStruct.new(
        id: 1,
        service_type: 'Entretien annuel',
        professional_name: 'AutoPro Garage',
        vehicle_model: 'Peugeot 208',
        scheduled_at: DateTime.current + 2.days,
        status: 'confirmed',
        price: 120.00,
        travel_fee: 15.00,
        description: 'Entretien complet avec vidange',
        reviewed?: false
      ),
      OpenStruct.new(
        id: 2,
        service_type: 'Vidange',
        professional_name: 'Méca Express',
        vehicle_model: 'Renault Clio',
        scheduled_at: DateTime.current + 5.days,
        status: 'pending',
        price: 85.00,
        travel_fee: 10.00,
        description: 'Vidange simple',
        reviewed?: false
      ),
      OpenStruct.new(
        id: 3,
        service_type: 'Lavage complet',
        professional_name: 'Clean Car Pro',
        vehicle_model: 'Peugeot 208',
        scheduled_at: DateTime.current - 5.days,
        status: 'completed',
        price: 50.00,
        travel_fee: 0,
        description: 'Lavage intérieur et extérieur',
        reviewed?: false
      ),
      OpenStruct.new(
        id: 4,
        service_type: 'Révision complète',
        professional_name: 'Garage Martin',
        vehicle_model: 'Citroën C3',
        scheduled_at: DateTime.current - 15.days,
        status: 'completed',
        price: 200.00,
        travel_fee: 20.00,
        description: 'Révision des 30000 km',
        reviewed?: true
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
