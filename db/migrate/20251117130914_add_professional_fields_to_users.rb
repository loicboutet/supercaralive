class AddProfessionalFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :siret, :string
    add_column :users, :intervention_zone, :string
    add_column :users, :professional_presentation, :text
  end
end
