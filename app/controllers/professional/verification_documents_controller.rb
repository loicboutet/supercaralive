class Professional::VerificationDocumentsController < Professional::BaseController
  def index
    @documents = current_user.professional_documents.order(created_at: :desc)
    @document = ProfessionalDocument.new
  end

  def create
    @document = current_user.professional_documents.build(document_params)
    
    if @document.save
      respond_to do |format|
        format.html { redirect_to professional_verification_documents_path, notice: "Document téléchargé avec succès." }
        format.json { render json: @document }
      end
    else
      @documents = current_user.professional_documents.order(created_at: :desc)
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: { errors: @document.errors }, status: :unprocessable_entity }
      end
    end
  end

  def update
    @document = current_user.professional_documents.find(params[:id])
    
    if @document.update(document_params)
      respond_to do |format|
        format.html { redirect_to professional_verification_documents_path, notice: "Document mis à jour avec succès." }
        format.json { render json: @document }
      end
    else
      respond_to do |format|
        format.html { redirect_to professional_verification_documents_path, alert: "Erreur lors de la mise à jour du document." }
        format.json { render json: { errors: @document.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @document = current_user.professional_documents.find(params[:id])
    @document.destroy
    
    respond_to do |format|
      format.html { redirect_to professional_verification_documents_path, notice: "Document supprimé avec succès." }
      format.json { head :no_content }
    end
  end

  private

  def document_params
    params.require(:professional_document).permit(:name, :comments, :file)
  end
end
