class Admin::UsersController < ApplicationController
  layout 'admin'
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy, :suspend, :activate, :deactivate]

  # GET /admin/users
  def index
    @users = User.all
    
    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @users = @users.where(
        "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(email) LIKE ?",
        search_term, search_term, search_term
      )
    end
    
    # Apply type filter
    if params[:type].present? && params[:type] != "all"
      case params[:type]
      when "client"
        @users = @users.client
      when "professional"
        @users = @users.professional
      when "admin"
        @users = @users.admin
      end
    end
    
    # Apply status filter
    if params[:status].present? && params[:status] != "all"
      @users = @users.where(status: params[:status])
    end
    
    # Calculate statistics
    @total_users = User.count
    @total_clients = User.client.count
    @total_professionals = User.professional.count
    @new_this_month = User.where("created_at >= ?", Date.current.beginning_of_month).count
    
    # Order and paginate
    @users = @users.order(created_at: :desc)
    @pagy, @users = pagy(@users, items: 10)
  end

  # GET /admin/users/:id
  def show
    if @user.client?
      # Load recent bookings for client
      @recent_bookings = @user.client_bookings.includes(:professional, :professional_service, :vehicle)
                                .order(created_at: :desc)
                                .limit(5)
      # Load vehicles for client
      @vehicles = @user.vehicles.order(created_at: :desc)
    elsif @user.professional?
      # Load professional documents
      @documents = @user.professional_documents.order(created_at: :desc)
    end
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # POST /admin/users
  def create
    @user = User.new(user_params)
    
    # Set cgu_accepted to true when created by admin
    @user.cgu_accepted = true
    
    # Skip professional welcome email (admin sends welcome_email instead)
    @user.skip_professional_welcome_email = true
    
    # Set status to active when created by admin
    @user.status = "active"
    
    # Generate a temporary password
    temp_password = Devise.friendly_token.first(12)
    @user.password = temp_password
    @user.password_confirmation = temp_password
    
    if @user.save
      # Send welcome email with temporary password
      UserMailer.welcome_email(@user, temp_password).deliver_later
      
      respond_to do |format|
        format.html { redirect_to admin_user_path(@user), notice: "Utilisateur créé avec succès." }
        format.json { render :show, status: :created, location: admin_user_path(@user) }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /admin/users/:id/edit
  def edit
  end

  # PATCH/PUT /admin/users/:id
  def update
    update_params = admin_update_params.dup
    
    # Only update password if provided
    if update_params[:password].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end
    
    if @user.update(update_params)
      respond_to do |format|
        format.html { redirect_to admin_user_path(@user), notice: "Utilisateur mis à jour avec succès." }
        format.json { render :show, status: :ok, location: admin_user_path(@user) }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/:id
  def destroy
    @user.destroy
    
    respond_to do |format|
      format.html { redirect_to admin_users_path, notice: "Utilisateur supprimé avec succès." }
      format.json { head :no_content }
    end
  end

  # PATCH /admin/users/:id/suspend
  def suspend
    @user.update(status: :suspended)
    
    respond_to do |format|
      format.html { redirect_to admin_user_path(@user), notice: "Utilisateur suspendu avec succès." }
      format.json { render :show, status: :ok, location: admin_user_path(@user) }
    end
  end

  # PATCH /admin/users/:id/activate
  def activate
    @user.update(status: :active)
    
    respond_to do |format|
      format.html { redirect_to admin_user_path(@user), notice: "Utilisateur activé avec succès." }
      format.json { render :show, status: :ok, location: admin_user_path(@user) }
    end
  end

  # PATCH /admin/users/:id/deactivate
  def deactivate
    @user.update(status: :inactive)
    
    respond_to do |format|
      format.html { redirect_to admin_user_path(@user), notice: "Utilisateur désactivé avec succès." }
      format.json { render :show, status: :ok, location: admin_user_path(@user) }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :role, :status, :phone_number, :location, :password, :password_confirmation)
  end

  def admin_update_params
    # Exclude first_name, last_name, phone_number, and location from admin update
    params.require(:user).permit(:email, :role, :status, :password, :password_confirmation)
  end
end
