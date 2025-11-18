class BookingMailer < ApplicationMailer
  def client_booking_confirmation(booking)
    @booking = booking
    @client = booking.client
    @professional = booking.professional
    @vehicle = booking.vehicle
    @professional_service = booking.professional_service
    
    professional_name = @professional.company_name.presence || @professional.get_full_name
    mail(to: @client.email, subject: "Confirmation de votre réservation avec #{professional_name}")
  end

  def professional_booking_notification(booking)
    @booking = booking
    @client = booking.client
    @professional = booking.professional
    @vehicle = booking.vehicle
    @professional_service = booking.professional_service
    
    mail(to: @professional.email, subject: "Nouvelle réservation : #{@professional_service.name}")
  end

  def professional_booking_reminder(booking)
    @booking = booking
    @professional = booking.professional
    @client = booking.client
    @vehicle = booking.vehicle
    @professional_service = booking.professional_service
    
    mail(to: @professional.email, subject: "Rappel : Rendez-vous dans 7 jours - #{@professional_service.name}")
  end

  def client_booking_reminder(booking)
    @booking = booking
    @client = booking.client
    @professional = booking.professional
    @vehicle = booking.vehicle
    @professional_service = booking.professional_service
    
    professional_name = @professional.company_name.presence || @professional.get_full_name
    mail(to: @client.email, subject: "Rappel : Votre rendez-vous approche - #{@professional_service.name}")
  end
end

