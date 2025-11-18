class Professional::ChatMessagesController < Professional::BaseController
  before_action :set_booking
  before_action :set_chat
  before_action :ensure_chat_exists

  def create
    @message = @chat.chat_messages.build(chat_message_params)
    @message.user = current_user

    respond_to do |format|
      if @message.save
        format.turbo_stream
        format.html { redirect_to professional_booking_path(@booking), notice: 'Message envoyé avec succès.' }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_form",
            partial: "chat_messages/message_form",
            locals: { chat: @chat, message: @message, booking: @booking, context: :professional }
          )
        end
        format.html { redirect_to professional_booking_path(@booking), alert: 'Erreur lors de l\'envoi du message.' }
      end
    end
  end

  private

  def set_booking
    @booking = current_user.professional_bookings.find(params[:booking_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to professional_bookings_path, alert: 'Réservation introuvable.'
  end

  def set_chat
    @chat = @booking.chat
  end

  def ensure_chat_exists
    unless @chat
      redirect_to professional_booking_path(@booking), alert: 'Chat introuvable.'
    end
  end

  def chat_message_params
    params.require(:chat_message).permit(:content)
  end
end

