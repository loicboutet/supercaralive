class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pagy::Backend

  # Require authentication for ALL pages by default
  before_action :authenticate_user!
  # Check user status and redirect if blocked or inactive
  before_action :check_user_status

  private

  def check_user_status
    return unless user_signed_in?
    
    # Allow access to account status pages and logout
    return if controller_name == 'account_status'
    return if controller_name == 'sessions' && action_name == 'destroy'
    
    # Redirect based on status
    if current_user.suspended?
      redirect_to account_status_suspended_path unless request.path == '/account_status/suspended'
    elsif current_user.inactive?
      redirect_to account_status_inactive_path unless request.path == '/account_status/inactive'
    end
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès refusé. Vous devez être administrateur."
    end
  end
end
