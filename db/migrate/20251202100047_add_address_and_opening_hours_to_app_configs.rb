class AddAddressAndOpeningHoursToAppConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :app_configs, :address, :text
    add_column :app_configs, :opening_hours, :text
  end
end
