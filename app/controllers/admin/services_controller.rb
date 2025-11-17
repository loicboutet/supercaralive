class Admin::ServicesController < ApplicationController
  layout 'admin'
  before_action :require_admin
  before_action :set_service, only: [:show, :edit, :update, :destroy]

  # GET /admin/services
  def index
    @services = Service.all

    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @services = @services.where(
        "LOWER(name) LIKE ? OR LOWER(description) LIKE ?",
        search_term, search_term
      )
    end

    # Apply category filter
    if params[:category].present? && params[:category] != "all"
      @services = @services.where(category: params[:category])
    end

    # Apply status filter
    if params[:status].present? && params[:status] != "all"
      case params[:status]
      when "active"
        @services = @services.where(active: true)
      when "inactive"
        @services = @services.where(active: false)
      when "popular"
        @services = @services.where(popular: true)
      end
    end

    # Calculate statistics
    @total_count = Service.count
    @mecanique_count = Service.where(category: 'mecanique').count
    @carrosserie_count = Service.where(category: 'carrosserie').count
    @lavage_count = Service.where(category: 'lavage').count

    # Order and paginate
    @services = @services.order(created_at: :desc)
    @pagy, @services = pagy(@services, items: 10)
  end

  # GET /admin/services/:id
  def show
  end

  # GET /admin/services/new
  def new
    @service = Service.new
  end

  # GET /admin/services/:id/edit
  def edit
  end

  # POST /admin/services
  def create
    @service = Service.new(service_params)

    if @service.save
      respond_to do |format|
        format.html { redirect_to admin_services_path, notice: "Service créé avec succès." }
        format.json { render json: { status: "success", message: "Service créé avec succès." } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @service.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /admin/services/:id
  def update
    if @service.update(service_params)
      respond_to do |format|
        format.html { redirect_to admin_service_path(@service), notice: "Service mis à jour avec succès." }
        format.json { render json: { status: "success", message: "Service mis à jour avec succès." } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @service.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/services/:id
  def destroy
    @service.destroy
    respond_to do |format|
      format.html { redirect_to admin_services_path, notice: "Service supprimé avec succès." }
      format.json { render json: { status: "success", message: "Service supprimé avec succès." } }
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(
      :name, :description, :category, :icon, :estimated_duration,
      :suggested_price, :active, :popular, :requires_quote,
      :prerequisites, :internal_notes
    )
  end
end
