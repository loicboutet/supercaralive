class Professional::ManualBookingsController < Professional::BaseController
  def new
    @booking = Booking.new
    @booking.professional_id = current_user.id
    # No client_id for manual bookings - they are created by professional for themselves
    @booking.manual_booking = true
    @professional_services = current_user.professional_services.where(active: true).order(:name)
    
    render partial: 'professional/manual_bookings/form', locals: { booking: @booking, professional_services: @professional_services }
  end

  def create
    @booking = Booking.new(manual_booking_params)
    @booking.professional_id = current_user.id
    # No client_id for manual bookings - they are created by professional for themselves
    @booking.manual_booking = true
    @booking.manual = true # Mark as manual booking
    @booking.status = :accepted # Auto-accept manual bookings
    
    if @booking.save
      respond_to do |format|
        format.html { redirect_to calendar_professional_availability_slots_path, notice: 'Réservation créée avec succès.' }
      end
    else
      @professional_services = current_user.professional_services.where(active: true).order(:name)
      respond_to do |format|
        format.html { 
          flash[:alert] = @booking.errors.full_messages.join(", ")
          redirect_to calendar_professional_availability_slots_path
        }
      end
    end
  end

  private

  def manual_booking_params
    params.require(:booking).permit(:professional_service_id, :scheduled_at, :description)
  end
end

