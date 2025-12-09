# == Schema Information
#
# Table name: bookings
# Database name: primary
#
#  id                         :integer          not null, primary key
#  client_reminder_sent       :boolean          default(FALSE), not null
#  current_mileage            :integer
#  description                :text
#  estimated_price            :decimal(8, 2)
#  intervention_address       :text
#  manual                     :boolean          default(FALSE), not null
#  professional_reminder_sent :boolean          default(FALSE), not null
#  scheduled_at               :datetime
#  status                     :string           default("pending"), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  client_id                  :integer
#  professional_id            :integer          not null
#  professional_service_id    :integer          not null
#  vehicle_id                 :integer
#
# Indexes
#
#  index_bookings_on_client_id                (client_id)
#  index_bookings_on_professional_id          (professional_id)
#  index_bookings_on_professional_service_id  (professional_service_id)
#  index_bookings_on_status                   (status)
#  index_bookings_on_vehicle_id               (vehicle_id)
#
# Foreign Keys
#
#  client_id                (client_id => users.id)
#  professional_id          (professional_id => users.id)
#  professional_service_id  (professional_service_id => professional_services.id)
#  vehicle_id               (vehicle_id => vehicles.id)
#
class Booking < ApplicationRecord
  belongs_to :client, class_name: "User", optional: true
  belongs_to :professional, class_name: "User"
  belongs_to :vehicle, optional: true
  belongs_to :professional_service
  has_one :chat, dependent: :destroy

  # Virtual attribute to mark manual bookings (created by professional for themselves)
  attr_accessor :manual_booking

  # Status enum
  enum :status, {
    pending: "pending",
    accepted: "accepted",
    refused: "refused",
    cancelled: "cancelled",
    completed: "completed"
  }, default: :pending

  # Validations
  validates :client_id, presence: true, unless: :manual_booking?
  validates :professional_id, presence: true
  validates :vehicle_id, presence: true, unless: :manual_booking?
  validates :professional_service_id, presence: true
  validates :status, presence: true
  validates :scheduled_at, presence: true
  validates :current_mileage, presence: true, numericality: { greater_than_or_equal_to: 0 }, unless: :manual_booking?
  validates :description, presence: true
  validates :intervention_address, presence: true, unless: :manual_booking?

  # Scopes
  scope :for_client, ->(client) { where(client_id: client.id) }
  scope :for_professional, ->(professional) { where(professional_id: professional.id) }
  scope :pending_or_accepted, -> { where(status: [:pending, :accepted]) }
  scope :completed, -> { where(status: :completed) }
  scope :cancelled, -> { where(status: :cancelled) }
  scope :refused, -> { where(status: :refused) }
  scope :past_and_not_completed, -> { where.not(status: :completed).where("scheduled_at < ?", Time.current) }

  # Ensure client is actually a client
  validate :client_must_be_client
  # Ensure professional is actually a professional
  validate :professional_must_be_professional
  # Ensure vehicle belongs to client
  validate :vehicle_must_belong_to_client
  # Ensure professional_service belongs to professional
  validate :professional_service_must_belong_to_professional

  # Calculate estimated price from professional_service
  before_validation :set_estimated_price, on: :create
  
  # Create chat automatically when booking is created by a client
  after_create :create_chat_if_client_booking
  
  # Update popular services when a booking is completed
  after_update :update_popular_services, if: :saved_change_to_status?

  def professional_name
    return "Professionnel supprimé" unless professional.present?
    professional.company_name.presence || professional.get_full_name
  end

  def vehicle_model
    return nil unless vehicle.present?
    brand = vehicle.brand.presence || "Marque inconnue"
    model = vehicle.model.presence || "Modèle inconnu"
    year = vehicle.year.present? ? vehicle.year : "Année inconnue"
    "#{brand} #{model} (#{year})"
  end

  def service_type_name
    return "Service supprimé" unless professional_service.present?
    professional_service.name
  end

  def reviewed?
    # Placeholder method - reviews feature not yet implemented
    false
  end

  private

  def client_must_be_client
    return if manual_booking? # Skip validation for manual bookings (professional creates for themselves)
    if client.present? && !client.client?
      errors.add(:client, "must be a client")
    end
  end

  def professional_must_be_professional
    if professional.present? && !professional.professional?
      errors.add(:professional, "must be a professional")
    end
  end

  def vehicle_must_belong_to_client
    return if manual_booking? # Skip validation for manual bookings
    if vehicle.present? && client.present? && vehicle.user_id != client_id
      errors.add(:vehicle, "must belong to the client")
    end
  end

  def manual_booking?
    manual_booking == true || manual_booking == "1" || manual_booking == "true"
  end

  def professional_service_must_belong_to_professional
    if professional_service.present? && professional.present? && professional_service.user_id != professional_id
      errors.add(:professional_service, "must belong to the professional")
    end
  end

  def set_estimated_price
    return unless professional_service.present?

    case professional_service.pricing_type
    when "flat_rate"
      self.estimated_price = professional_service.flat_rate_price
    when "hourly_rate"
      # For hourly rate, we can't estimate without duration, so we'll leave it nil
      # The professional will set the final price
      self.estimated_price = nil
    end
  end

  def create_chat_if_client_booking
    # Only create chat if booking has a client (not a manual booking created by professional)
    if client.present? && !manual_booking?
      Chat.create(booking: self)
    end
  end

  def update_popular_services
    # Only update if booking status changed to completed
    return unless saved_change_to_status? && status == 'completed'
    
    # Update popular status for all services linked to this professional_service
    professional_service.services.find_each do |service|
      completed_bookings_count = service.bookings.where(status: :completed).count
      should_be_popular = completed_bookings_count >= Service::POPULAR_THRESHOLD
      
      if service.popular != should_be_popular
        service.update_column(:popular, should_be_popular)
      end
    end
  end
end
