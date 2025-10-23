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
      address: '123 Rue de Example',
      postal_code: '75001',
      city: 'Paris'
    )
  end
end
