class Users::RegistrationsController < Devise::RegistrationsController
  # Allow unauthenticated access to registration pages
  skip_before_action :authenticate_user!, only: [:new, :create]
  
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :restrict_non_admin_access, only: [:edit, :update, :destroy]

  # GET /users/sign_up
  def new
    super
  end

  # POST /users
  def create
    build_resource(sign_up_params)
    
    # Set status based on role:
    # - Active for clients
    # - Inactive for professionals (need admin approval)
    if resource.client?
      resource.status = "active"
    elsif resource.professional?
      resource.status = "inactive"
    end
    
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /users/edit
  def edit
    super
  end

  # PUT /users
  def update
    super
  end

  # DELETE /users
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :first_name, :last_name, :phone, :cgu_accepted])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    if resource.client?
      client_root_path
    elsif resource.professional?
      professional_root_path
    elsif resource.admin?
      admin_root_path
    else
      root_path
    end
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  private

  def restrict_non_admin_access
    # Only admins can access /users/edit, /users (update), /users (destroy)
    # Clients and professionals should use their respective profile edit pages
    unless current_user&.admin?
      if current_user&.client?
        redirect_to edit_client_profile_path, alert: "Veuillez utiliser la page de modification de profil pour modifier vos informations."
      elsif current_user&.professional?
        redirect_to edit_professional_profile_path, alert: "Veuillez utiliser la page de modification de profil pour modifier vos informations."
      else
        redirect_to root_path, alert: "Accès refusé."
      end
    end
  end
end
