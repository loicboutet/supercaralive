class CreateAppConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :app_configs do |t|
      t.string :contact_phone
      t.string :contact_email
      t.text :terms_of_service
      t.text :privacy_policy

      t.timestamps
    end
  end
end
