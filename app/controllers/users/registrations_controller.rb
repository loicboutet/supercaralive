class Users::RegistrationsController < Devise::RegistrationsController
  # Allow unauthenticated access to registration pages
  skip_before_action :authenticate_user!, only: [:new, :create]
  
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /users/sign_up
  def new
    super
  end

  # POST /users
  def create
    super
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
end
