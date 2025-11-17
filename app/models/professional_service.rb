# == Schema Information
#
# Table name: professional_services
# Database name: primary
#
#  id                  :integer          not null, primary key
#  active              :boolean          default(TRUE), not null
#  duration_minutes    :integer
#  flat_rate_price     :decimal(8, 2)
#  hourly_rate_price   :decimal(8, 2)
#  name                :string           not null
#  price               :decimal(8, 2)
#  pricing_type        :string
#  travel_flat_rate    :decimal(8, 2)
#  travel_per_km_rate  :decimal(8, 2)
#  travel_pricing_type :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer          not null
#
# Indexes
#
#  index_professional_services_on_active   (active)
#  index_professional_services_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class ProfessionalService < ApplicationRecord
  belongs_to :user
  has_many :professional_service_services, dependent: :destroy
  has_many :services, through: :professional_service_services

  # Pricing types
  PRICING_TYPES = %w[flat_rate hourly_rate].freeze
  TRAVEL_PRICING_TYPES = %w[flat_rate per_km].freeze

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true
  validates :pricing_type, inclusion: { in: PRICING_TYPES }, allow_nil: true
  validates :travel_pricing_type, inclusion: { in: TRAVEL_PRICING_TYPES }, allow_nil: true
  validates :flat_rate_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :hourly_rate_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :travel_flat_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :travel_per_km_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :must_have_at_least_one_service
  validate :must_have_pricing_type_and_price
  validate :must_have_travel_pricing_if_travel_price_set

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :for_user, ->(user) { where(user: user) }
  scope :flat_rate, -> { where(pricing_type: "flat_rate") }
  scope :hourly_rate, -> { where(pricing_type: "hourly_rate") }

  def toggle_active!
    update(active: !active)
  end

  def suggested_price
    return 0 if services.empty?
    services.sum(&:suggested_price) || 0
  end

  def suggested_duration
    return 0 if services.empty?
    services.sum(&:estimated_duration) || 0
  end

  def display_price
    return nil unless pricing_type.present?
    
    case pricing_type
    when "flat_rate"
      flat_rate_price.present? ? "#{sprintf('%.2f', flat_rate_price)}€" : nil
    when "hourly_rate"
      hourly_rate_price.present? ? "#{sprintf('%.2f', hourly_rate_price)}€/h" : nil
    end
  end

  def display_travel_price
    return nil unless travel_pricing_type.present?
    
    case travel_pricing_type
    when "flat_rate"
      travel_flat_rate.present? ? "#{sprintf('%.2f', travel_flat_rate)}€" : nil
    when "per_km"
      travel_per_km_rate.present? ? "#{sprintf('%.2f', travel_per_km_rate)}€/km" : nil
    end
  end

  private

  def must_have_at_least_one_service
    if service_ids.blank? && services.empty?
      errors.add(:base, "Vous devez sélectionner au moins un service")
    end
  end

  def must_have_pricing_type_and_price
    return if pricing_type.blank? # Allow nil for backward compatibility
    
    if pricing_type == "flat_rate" && flat_rate_price.blank?
      errors.add(:flat_rate_price, "doit être renseigné pour un prix forfait")
    elsif pricing_type == "hourly_rate" && hourly_rate_price.blank?
      errors.add(:hourly_rate_price, "doit être renseigné pour un prix horaire")
    end
  end

  def must_have_travel_pricing_if_travel_price_set
    return if travel_pricing_type.blank? && travel_flat_rate.blank? && travel_per_km_rate.blank?
    
    if travel_pricing_type == "flat_rate" && travel_flat_rate.blank?
      errors.add(:travel_flat_rate, "doit être renseigné pour un forfait de déplacement")
    elsif travel_pricing_type == "per_km" && travel_per_km_rate.blank?
      errors.add(:travel_per_km_rate, "doit être renseigné pour un prix par kilomètre")
    end
  end
end

