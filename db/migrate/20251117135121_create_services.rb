class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :icon
      t.integer :estimated_duration
      t.decimal :suggested_price, precision: 8, scale: 2
      t.boolean :active, default: true, null: false
      t.boolean :popular, default: false, null: false
      t.boolean :requires_quote, default: false, null: false
      t.text :prerequisites
      t.text :internal_notes

      t.timestamps
    end

    add_index :services, :category
    add_index :services, :active
  end
end
