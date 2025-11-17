class CreateProfessionalDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_documents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :file
      t.string :document_type

      t.timestamps
    end
  end
end
