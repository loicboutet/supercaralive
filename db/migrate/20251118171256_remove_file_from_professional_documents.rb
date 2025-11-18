class RemoveFileFromProfessionalDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :professional_documents, :file, :string
  end
end
