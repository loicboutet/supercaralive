class Admin::SpecialtiesController < ApplicationController
  layout 'admin'
  before_action :require_admin
  before_action :set_specialty, only: [:show, :edit, :update, :destroy]

  # GET /admin/specialties
  def index
    @specialties = Specialty.all

    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @specialties = @specialties.where("LOWER(name) LIKE ?", search_term)
    end

    # Calculate statistics
    @total_count = Specialty.count

    # Order and paginate
    @specialties = @specialties.order(created_at: :desc)
    @pagy, @specialties = pagy(@specialties, items: 10)
  end

  # GET /admin/specialties/:id
  def show
  end

  # GET /admin/specialties/new
  def new
    @specialty = Specialty.new
  end

  # GET /admin/specialties/:id/edit
  def edit
  end

  # POST /admin/specialties
  def create
    @specialty = Specialty.new(specialty_params)

    if @specialty.save
      respond_to do |format|
        format.html { redirect_to admin_specialties_path, notice: "Spécialité créée avec succès." }
        format.json { render json: { status: "success", message: "Spécialité créée avec succès." } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @specialty.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /admin/specialties/:id
  def update
    if @specialty.update(specialty_params)
      respond_to do |format|
        format.html { redirect_to admin_specialty_path(@specialty), notice: "Spécialité mise à jour avec succès." }
        format.json { render json: { status: "success", message: "Spécialité mise à jour avec succès." } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @specialty.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/specialties/:id
  def destroy
    @specialty.destroy
    respond_to do |format|
      format.html { redirect_to admin_specialties_path, notice: "Spécialité supprimée avec succès." }
      format.json { render json: { status: "success", message: "Spécialité supprimée avec succès." } }
    end
  end

  private

  def set_specialty
    @specialty = Specialty.find(params[:id])
  end

  def specialty_params
    params.require(:specialty).permit(:name, :icon)
  end
end

