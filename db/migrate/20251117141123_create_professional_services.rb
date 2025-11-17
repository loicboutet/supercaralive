class CreateProfessionalServices < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_services do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.integer :duration_minutes
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :professional_services, :user_id
    add_index :professional_services, :active
    add_foreign_key :professional_services, :users
  end
end
