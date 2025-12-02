class Admin::AppConfigsController < ApplicationController
  layout 'admin'
  before_action :require_admin
  before_action :set_app_config

  # GET /admin/app_config
  def show
  end

  # GET /admin/app_config/edit
  def edit
  end

  # PATCH /admin/app_config
  def update
    if @app_config.update(app_config_params)
      respond_to do |format|
        format.html { redirect_to admin_app_config_path, notice: "✅ La configuration a été mise à jour avec succès." }
        format.json { render json: { status: "success", message: "Configuration mise à jour avec succès." } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @app_config.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_app_config
    @app_config = AppConfig.instance
  end

  def app_config_params
    params.require(:app_config).permit(:contact_phone, :contact_email, :address, :opening_hours, :terms_of_service, :privacy_policy)
  end
end

