class AddDisplayCompleteNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :display_complete_name, :boolean, default: false, null: false
  end
end
