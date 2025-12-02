class Admin::ProfessionalApprovalsController < ApplicationController
  layout 'admin'
  before_action :require_admin
  before_action :set_user, only: [:show, :approve, :reject, :update_notes, :request_documents]

  # GET /admin/professional_approvals
  def index
    # Base query: only professional users
    @users = User.professional

    # Apply search filter (First Name, Last Name, Enterprise Name, Email)
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @users = @users.where(
        "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(company_name) LIKE ? OR LOWER(email) LIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    # Apply status filter
    if params[:status].present? && params[:status] != "all"
      @users = @users.where(status: params[:status])
    end

    # Calculate statistics
    @pending_count = User.professional.where(status: "inactive").count
    @approved_this_month = User.professional.where(status: "active")
      .where("created_at >= ?", Date.current.beginning_of_month).count
    @rejected_count = User.professional.where(status: "suspended").count
    @total_verified = User.professional.where(status: "active").count
    @urgent_requests = User.professional.where(status: "inactive")
      .where("created_at < ?", 48.hours.ago).count

    # Pending approvals list (for display in the pending section)
    @pending_users = User.professional.where(status: "inactive").order(created_at: :asc)
    
    # Apply search to pending users too
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @pending_users = @pending_users.where(
        "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(company_name) LIKE ? OR LOWER(email) LIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
    
    # Paginate pending users
    @pagy_pending, @pending_users = pagy(@pending_users, items: 10, page_param: :pending_page)

    # Recent decisions: professionals who are either active or suspended (recently changed)
    @recent_decisions = User.professional.where(status: ["active", "suspended"])
      .order(updated_at: :desc)
      .limit(10)
  end

  # GET /admin/professional_approvals/:id
  def show
    # Paginate documents
    @pagy_documents, @documents = pagy(@user.professional_documents.order(created_at: :desc), items: 10, page_param: :documents_page)
  end

  # PATCH /admin/professional_approvals/:id/approve
  def approve
    if @user.update(status: "active")
      respond_to do |format|
        format.html { redirect_to admin_professional_approvals_path, notice: "Utilisateur approuvé avec succès." }
        format.json { render json: { status: "success", message: "Utilisateur approuvé avec succès." } }
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_professional_approval_path(@user), alert: "Erreur lors de l'approbation." }
        format.json { render json: { status: "error", errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /admin/professional_approvals/:id/reject
  def reject
    if @user.update(status: "suspended")
      respond_to do |format|
        format.html { redirect_to admin_professional_approvals_path, notice: "Utilisateur refusé avec succès." }
        format.json { render json: { status: "success", message: "Utilisateur refusé avec succès." } }
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_professional_approval_path(@user), alert: "Erreur lors du refus." }
        format.json { render json: { status: "error", errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /admin/professional_approvals/:id/update_notes
  def update_notes
    if @user.update(admin_approval_note: params[:admin_approval_note])
      respond_to do |format|
        format.json { render json: { status: "success", message: "Notes enregistrées avec succès." } }
      end
    else
      respond_to do |format|
        format.json { render json: { status: "error", errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # POST /admin/professional_approvals/:id/request_documents
  def request_documents
    notes = params[:notes]&.strip
    # Checkbox sends "1" when checked, "0" when unchecked, or may be absent
    send_copy_to_admin = params[:send_copy_to_admin].present? && params[:send_copy_to_admin] != "0"
    
    if notes.blank?
      respond_to do |format|
        format.html { redirect_to admin_professional_approval_path(@user), alert: "Les notes sont obligatoires." }
        format.json { render json: { status: "error", errors: ["Les notes sont obligatoires."] }, status: :unprocessable_entity }
      end
      return
    end

    begin
      # Send email to professional
      UserMailer.document_request_email(@user, notes).deliver_now
      
      # Send copy to admin if requested
      if send_copy_to_admin
        UserMailer.document_request_email_copy(@user, notes, current_user.email).deliver_now
      end
      
      respond_to do |format|
        format.html { redirect_to admin_professional_approval_path(@user), notice: "✅ La demande de documents a été envoyée avec succès#{send_copy_to_admin ? ' (copie envoyée à votre adresse email)' : ''}." }
        format.json { render json: { status: "success", message: "Demande de documents envoyée avec succès." } }
      end
    rescue => e
      respond_to do |format|
        format.html { redirect_to admin_professional_approval_path(@user), alert: "Erreur lors de l'envoi de l'email : #{e.message}" }
        format.json { render json: { status: "error", errors: [e.message] }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.professional.find(params[:id])
  end
end
