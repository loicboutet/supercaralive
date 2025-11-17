class RemoveDocumentTypeAndAddCommentsToProfessionalDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :professional_documents, :document_type, :string
    add_column :professional_documents, :comments, :text
  end
end
