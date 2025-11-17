require 'ostruct'

class Client::ProfilesController < Client::BaseController
  before_action :set_profile, only: [:edit, :update]

  def show
    set_profile
  end

  def edit
    # @profile is set by before_action
  end

  def update
    if current_user.update(user_params)
      respond_to do |format|
        format.html { redirect_to client_profile_path, notice: 'Profil mis à jour avec succès.' }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_profile
    # Service locations and reminder settings remain as placeholders for now
    @profile = OpenStruct.new(
      # Service locations
      service_locations: [
        { id: 1, name: 'Domicile principal', address: '123 Rue de Example', postal_code: '75001', city: 'Paris', notes: 'Garage disponible' },
        { id: 2, name: 'Résidence secondaire', address: '45 Avenue des Pins', postal_code: '06400', city: 'Cannes', notes: 'Accès par le portail sud' }
      ],
      # Reminder settings
      reminders_enabled: true
    )
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :phone_number, :display_complete_name, :password, :password_confirmation)
          .tap do |permitted|
            # Only update password if provided
            if permitted[:password].blank?
              permitted.delete(:password)
              permitted.delete(:password_confirmation)
            end
          end
  end
end
