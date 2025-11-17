class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pagy::Backend

  # Require authentication for ALL pages by default
  before_action :authenticate_user!

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès refusé. Vous devez être administrateur."
    end
  end
end
