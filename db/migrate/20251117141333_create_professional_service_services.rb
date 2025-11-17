class CreateProfessionalServiceServices < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_service_services do |t|
      t.integer :professional_service_id, null: false
      t.integer :service_id, null: false

      t.timestamps
    end

    add_index :professional_service_services, :professional_service_id
    add_index :professional_service_services, :service_id
    add_index :professional_service_services, [:professional_service_id, :service_id], unique: true, name: 'index_prof_service_services_unique'
    add_foreign_key :professional_service_services, :professional_services
    add_foreign_key :professional_service_services, :services
  end
end
