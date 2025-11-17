class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    # Add column with default value
    add_column :users, :role, :string, default: "Client", null: false
    
    # Update existing records to have "Client" as default
    reversible do |dir|
      dir.up do
        execute "UPDATE users SET role = 'Client' WHERE role IS NULL OR role = ''"
      end
    end
  end
end
