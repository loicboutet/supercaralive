class Admin::ProfileController < ApplicationController
  layout 'admin'
  before_action :require_admin

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
    
    # Prepare update params
    update_params = profile_params.dup
    
    # Only update password if provided
    if update_params[:password].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end
    
    if @user.update(update_params)
      respond_to do |format|
        format.html { redirect_to admin_profile_path, notice: "Votre profil a été mis à jour avec succès." }
        format.json { render json: @user }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @user.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      :first_name, 
      :last_name, 
      :email, 
      :profile_photo,
      :password,
      :password_confirmation
    )
  end
end

