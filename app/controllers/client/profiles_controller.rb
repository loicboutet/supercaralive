require 'ostruct'

class Client::ProfilesController < Client::BaseController
  before_action :set_profile, only: [:edit, :update]

  def show
    # Current user profile would come from current_user in production
    set_profile
  end

  def edit
    # @profile is set by before_action
  end

  def update
    # In production, this would update database
    redirect_to client_profile_path, notice: 'Profil mis à jour avec succès.'
  end

  private

  def set_profile
    @profile = OpenStruct.new(
      pseudonym: 'J.D.',
      phone: '+33 6 12 34 56 78',
      # Billing address (for invoicing)
      billing_address: '123 Rue de Example',
      billing_postal_code: '75001',
      billing_city: 'Paris',
      # Service locations
      service_locations: [
        { id: 1, name: 'Domicile principal', address: '123 Rue de Example', postal_code: '75001', city: 'Paris', notes: 'Garage disponible' },
        { id: 2, name: 'Résidence secondaire', address: '45 Avenue des Pins', postal_code: '06400', city: 'Cannes', notes: 'Accès par le portail sud' }
      ],
      # Reminder settings
      reminders_enabled: true
    )
  end
end
