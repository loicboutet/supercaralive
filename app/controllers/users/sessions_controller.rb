class Users::SessionsController < Devise::SessionsController
  # Allow unauthenticated access to sign in pages
  skip_before_action :authenticate_user!, only: [:new, :create]
  # Skip require_no_authentication to handle redirect manually
  skip_before_action :require_no_authentication, only: [:new]
  # Skip status check for logout to allow blocked/inactive users to sign out
  skip_before_action :check_user_status, only: [:destroy]
  
  # GET /users/sign_in
  def new
    # Redirect authenticated users to their dashboard
    if user_signed_in?
      redirect_to determine_redirect_path_for(current_user)
    else
      super
    end
  end

  # POST /users/sign_in
  def create
    super
  end

  # DELETE /users/sign_out
  def destroy
    super
  end

  protected

  # Determine redirect path for authenticated users
  def determine_redirect_path_for(resource)
    if resource.admin?
      admin_root_path
    elsif resource.professional?
      # Inactive professionals should go to their profile page
      if resource.inactive?
        professional_profile_path
      else
        professional_root_path
      end
    elsif resource.client?
      client_root_path
    else
      # Fallback to root if role is unclear
      root_path
    end
  end

  # The path used after sign in.
  def after_sign_in_path_for(resource)
    # Inactive professionals should go to their profile page
    if resource.professional? && resource.inactive?
      professional_profile_path
    else
      determine_redirect_path_for(resource)
    end
  end

  # The path used after sign out.
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
