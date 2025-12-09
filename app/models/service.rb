# == Schema Information
#
# Table name: services
# Database name: primary
#
#  id                 :integer          not null, primary key
#  active             :boolean          default(TRUE), not null
#  category           :string           not null
#  description        :text             not null
#  estimated_duration :integer
#  icon               :string
#  internal_notes     :text
#  name               :string           not null
#  popular            :boolean          default(FALSE), not null
#  prerequisites      :text
#  requires_quote     :boolean          default(FALSE), not null
#  suggested_price    :decimal(8, 2)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_services_on_active    (active)
#  index_services_on_category  (category)
#
class Service < ApplicationRecord
  # Associations
  has_many :professional_service_services, dependent: :destroy
  has_many :professional_services, through: :professional_service_services
  has_many :bookings, through: :professional_services

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :category, presence: true, inclusion: { in: %w[mecanique carrosserie lavage detailing] }
  validates :suggested_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :estimated_duration, numericality: { greater_than: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :popular, -> { where(popular: true) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  
  # Class methods for automatic popular calculation
  # A service is considered popular if it has at least 10 completed bookings
  POPULAR_THRESHOLD = 10

  # Calculate and update popular status for all services
  def self.update_popular_services!
    Service.find_each do |service|
      completed_bookings_count = service.bookings.where(status: :completed).count
      should_be_popular = completed_bookings_count >= POPULAR_THRESHOLD
      
      if service.popular != should_be_popular
        service.update_column(:popular, should_be_popular)
      end
    end
  end
  
  # Instance method to check if service should be popular based on bookings
  def should_be_popular?
    bookings.where(status: :completed).count >= POPULAR_THRESHOLD
  end
  
  # Get count of completed bookings for this service
  def completed_bookings_count
    bookings.where(status: :completed).count
  end

  # Category helpers
  def mecanique?
    category == 'mecanique'
  end

  def carrosserie?
    category == 'carrosserie'
  end

  def lavage?
    category == 'lavage'
  end

  def detailing?
    category == 'detailing'
  end
end
