class AddPricingFieldsToProfessionalServices < ActiveRecord::Migration[8.0]
  def change
    add_column :professional_services, :pricing_type, :string
    add_column :professional_services, :flat_rate_price, :decimal, precision: 8, scale: 2
    add_column :professional_services, :hourly_rate_price, :decimal, precision: 8, scale: 2
    add_column :professional_services, :travel_pricing_type, :string
    add_column :professional_services, :travel_flat_rate, :decimal, precision: 8, scale: 2
    add_column :professional_services, :travel_per_km_rate, :decimal, precision: 8, scale: 2
    
    # Make price nullable for backward compatibility
    change_column_null :professional_services, :price, true
  end
end
