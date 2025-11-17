class AddStatusPhoneNumberLocationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :status, :string, default: "active"
    add_column :users, :phone_number, :string
    add_column :users, :location, :string
  end
end
