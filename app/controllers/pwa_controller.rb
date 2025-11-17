class PwaController < ApplicationController
  # Service worker and manifest should be accessible without authentication
  skip_before_action :authenticate_user!, only: [:service_worker, :manifest]
  # Service workers must be served without CSRF protection
  skip_before_action :verify_authenticity_token, only: [:service_worker]

  def service_worker
    respond_to do |format|
      format.js { render template: 'pwa/service-worker', content_type: 'application/javascript' }
    end
  end

  def manifest
    respond_to do |format|
      format.json { render template: 'pwa/manifest', content_type: 'application/manifest+json' }
    end
  end
end

