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
      # For inactive professionals, allow access to profile pages and verification documents
      if current_user.professional?
        allowed_paths = [
          professional_profile_path,
          edit_professional_profile_path,
          professional_verification_documents_path
        ]
        allowed_controllers = ['profile', 'verification_documents']
        allowed_actions = ['show', 'edit', 'update', 'index', 'create', 'destroy']
        
        # Check if we're in the professional namespace
        is_professional_namespace = request.path.start_with?('/professional')
        
        # Allow if accessing allowed controller/action in professional namespace or if path matches allowed paths
        is_allowed = is_professional_namespace &&
                     allowed_controllers.include?(controller_name) && 
                     allowed_actions.include?(action_name)
        
        unless is_allowed || allowed_paths.any? { |path| request.path == path }
          redirect_to professional_profile_path, alert: "Votre compte est en attente de validation. Veuillez compléter votre profil."
        end
      else
        # For inactive clients, redirect to inactive page
        redirect_to account_status_inactive_path unless request.path == '/account_status/inactive'
      end
    end
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès refusé. Vous devez être administrateur."
    end
  end
end
