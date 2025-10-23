require 'ostruct'

class Client::PaymentsController < Client::BaseController
  before_action :set_booking, only: [:show, :success, :cancel]

  def create
    # In production, this would create a Stripe payment intent
    redirect_to success_client_payments_path(booking_id: params[:booking_id])
  end

  def show
    # @booking is set by before_action
    # This page displays the Stripe payment form
  end

  def success
    # @booking is set by before_action
    # Payment success confirmation page
  end

  def cancel
    # @booking is set by before_action
    # Payment cancelled page
  end

  private

  def set_booking
    @booking = OpenStruct.new(
      id: params[:booking_id] || params[:id] || 1,
      service_type: 'Entretien annuel',
      professional_name: 'AutoPro Garage',
      scheduled_at: DateTime.current + 2.days,
      price: 120.00,
      travel_fee: 15.00
    )
  end
end
