class HomeController < ApplicationController
  layout "home"
  
  def index
    # Redirect authenticated users to their appropriate dashboard based on role
    if user_signed_in?
      if current_user.admin?
        redirect_to admin_root_path
      elsif current_user.professional?
        redirect_to professional_root_path
      elsif current_user.client?
        redirect_to client_root_path
      else
        redirect_to new_user_session_path
      end
    else
      redirect_to new_user_session_path
    end
  end
end
