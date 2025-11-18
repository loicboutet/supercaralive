class Professional::BookingsController < Professional::BaseController
  include Pagy::Backend
  
  before_action :set_booking, only: [:accept, :refuse, :complete]
  before_action :set_booking_with_associations, only: [:show]

  def index
    @bookings = current_user.professional_bookings
                            .includes(:client, :vehicle, :professional_service)
                            .order(created_at: :desc)
    
    # Filter by status
    if params[:status].present? && params[:status] != "all"
      @bookings = @bookings.where(status: params[:status])
    end
    
    # Paginate
    @pagy, @bookings = pagy(@bookings, items: 10)
    
    # Count bookings by status for tabs
    all_bookings = current_user.professional_bookings
    @pending_count = all_bookings.where(status: :pending).count
    @accepted_count = all_bookings.where(status: :accepted).count
    @completed_count = all_bookings.where(status: :completed).count
    @cancelled_count = all_bookings.where(status: :cancelled).count
    @refused_count = all_bookings.where(status: :refused).count
  end

  def show
    # @booking is set by before_action set_booking_with_associations
  end

  def accept
    if @booking.update(status: :accepted)
      respond_to do |format|
        format.html { redirect_to professional_booking_path(@booking), notice: "Réservation acceptée avec succès." }
        format.json { render json: { status: "success", message: "Réservation acceptée avec succès." } }
      end
    else
      respond_to do |format|
        format.html { redirect_to professional_booking_path(@booking), alert: "Erreur lors de l'acceptation de la réservation." }
        format.json { render json: { status: "error", errors: @booking.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def refuse
    if @booking.update(status: :refused)
      respond_to do |format|
        format.html { redirect_to professional_booking_path(@booking), notice: "Réservation refusée." }
        format.json { render json: { status: "success", message: "Réservation refusée." } }
      end
    else
      respond_to do |format|
        format.html { redirect_to professional_booking_path(@booking), alert: "Erreur lors du refus de la réservation." }
        format.json { render json: { status: "error", errors: @booking.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def complete
    if @booking.update(status: :completed)
      respond_to do |format|
        format.html { redirect_to professional_bookings_path, notice: "Réservation marquée comme terminée." }
        format.json { render json: { status: "success", message: "Réservation marquée comme terminée." } }
      end
    else
      respond_to do |format|
        format.html { redirect_to professional_bookings_path, alert: "Erreur lors du marquage de la réservation comme terminée." }
        format.json { render json: { status: "error", errors: @booking.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_booking
    @booking = current_user.professional_bookings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to professional_bookings_path, alert: "Réservation introuvable."
  end

  def set_booking_with_associations
    @booking = current_user.professional_bookings
                            .includes(:client, :vehicle, professional_service: :services)
                            .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to professional_bookings_path, alert: "Réservation introuvable."
  end
end
