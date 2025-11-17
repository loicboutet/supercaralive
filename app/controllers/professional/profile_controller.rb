class Professional::ProfileController < Professional::BaseController
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    
    # Handle profile photo deletion before update
    if params[:user][:remove_profile_photo] == '1'
      @user.profile_photo.purge if @user.profile_photo.attached?
    end
    
    if @user.update(profile_params)
      respond_to do |format|
        format.html { redirect_to professional_profile_path, notice: "Votre profil a été mis à jour avec succès." }
        format.json { render json: @user }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @user.errors }, status: :unprocessable_entity }
      end
    end
  end

  def preview
    @user = current_user
  end

  private

  def profile_params
    params.require(:user).permit(
      :first_name, 
      :last_name, 
      :company_name, 
      :email, 
      :phone_number, 
      :location,
      :siret,
      :intervention_zone,
      :professional_presentation,
      :profile_photo
    )
  end
end
