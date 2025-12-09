# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                                 :integer          not null, primary key
#  address                            :text
#  admin_approval_note                :text
#  cgu_accepted                       :boolean          default(FALSE), not null
#  client_booking_reminder            :boolean          default(TRUE), not null
#  client_booking_reminder_sent       :boolean          default(FALSE), not null
#  company_name                       :string
#  display_complete_name              :boolean          default(FALSE), not null
#  email                              :string           default(""), not null
#  encrypted_password                 :string           default(""), not null
#  first_name                         :string
#  intervention_zone                  :string
#  last_name                          :string
#  latitude                           :decimal(10, 6)
#  location                           :string
#  longitude                          :decimal(10, 6)
#  maintenance_reminders_enabled      :boolean          default(TRUE), not null
#  phone_number                       :string
#  professional_booking_notification  :boolean          default(TRUE), not null
#  professional_booking_reminder      :boolean          default(TRUE), not null
#  professional_booking_reminder_sent :boolean          default(FALSE), not null
#  professional_presentation          :text
#  remember_created_at                :datetime
#  reset_password_sent_at             :datetime
#  reset_password_token               :string
#  role                               :string           default("client"), not null
#  siret                              :string
#  status                             :string           default("active")
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
# Indexes
#
#  index_users_on_email                   (email) UNIQUE
#  index_users_on_latitude_and_longitude  (latitude,longitude)
#  index_users_on_reset_password_token    (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  include AvailabilitySlots
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Explicit attribute type declarations for string-based enums (Rails 8 requirement)
  attribute :role, :string
  attribute :status, :string
  
  # Role validation
  enum :role, { client: "Client", professional: "Professional", admin: "Admin" }
  
  # Status validation
  enum :status, { active: "active", inactive: "inactive", suspended: "suspended" }
  
  # Virtual attribute to skip professional welcome email when created by admin
  attr_accessor :skip_professional_welcome_email

  # Associations
  has_many :professional_documents, dependent: :destroy
  has_many :professional_services, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :custom_availabilities, dependent: :destroy
  has_many :client_bookings, class_name: "Booking", foreign_key: "client_id", dependent: :destroy
  has_many :professional_bookings, class_name: "Booking", foreign_key: "professional_id", dependent: :destroy
  has_one_attached :profile_photo
  has_and_belongs_to_many :specialties

  # Geocoding configuration
  geocoded_by :location
  after_validation :geocode, if: ->(obj) { obj.location.present? && (obj.location_changed? || obj.latitude.blank? || obj.longitude.blank?) }

  # Set default role and status before validation
  before_validation :set_default_role, on: :create
  before_validation :set_default_status, on: :create
  before_validation :normalize_role
  
  # Send welcome email to professionals after creation (only for self-registration)
  after_create :send_professional_welcome_email, if: -> { professional? && !skip_professional_welcome_email }
  
  # Override role writer to normalize case-insensitive values
  def role=(value)
    normalized_value = normalize_role_value(value)
    super(normalized_value)
  end
  
  # CGU acceptance validation (required only for user self-registration)
  validates :cgu_accepted, acceptance: { message: "Vous devez accepter les conditions d'utilisation" }, on: :create

  # First name and last name are required only for clients (on create)
  validates :first_name, presence: { message: "Le prénom est obligatoire" }, if: -> { client? }, on: :create
  validates :last_name, presence: { message: "Le nom est obligatoire" }, if: -> { client? }, on: :create

  # Role check methods (case-insensitive)
  def client?
    role.present? && role.downcase == "client"
  end

  def professional?
    role.present? && role.downcase == "professional"
  end

  def admin?
    role.present? && role.downcase == "admin"
  end

  def get_full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    else
      email
    end
  end

  def get_initials
    if first_name.present? && last_name.present?
      "#{first_name.first.upcase}#{last_name.first.upcase}"
    elsif first_name.present?
      first_name.first.upcase
    else
      email.first.upcase
    end
  end

  def pseudonym
    get_initials
  end
  
  # Returns normalized role value for use in select forms
  def normalized_role_for_select
    normalize_role_value(role)
  end
  
  # Calculate profile completion percentage for professionals
  # Includes: fields, profile photo, and at least one document
  def profile_completion_percentage
    return 0 unless professional?
    
    fields = [:first_name, :last_name, :company_name, :email, :phone_number, :location, :siret, :intervention_zone, :professional_presentation]
    completed_fields = fields.count { |field| send(field).present? }
    profile_photo_completed = profile_photo.attached?
    document_completed = professional_documents.exists?
    
    total_fields = fields.count + 1 + 1 # fields + profile photo + document
    completed_total = completed_fields + (profile_photo_completed ? 1 : 0) + (document_completed ? 1 : 0)
    
    ((completed_total.to_f / total_fields) * 100).round
  end
  
  # Calculate the next available time slot for this professional
  # Returns a hash with :datetime, :date, and :time, or nil if no availability found
  def next_availability
    return nil unless professional?
    
    # Get existing bookings that block availability (pending or accepted) with their durations
    conflicting_bookings = professional_bookings
                              .where(status: [:pending, :accepted])
                              .where.not(scheduled_at: nil)
                              .includes(:professional_service)
                              .map do |booking|
                                duration_minutes = booking.professional_service&.duration_minutes || 60
                                {
                                  start: booking.scheduled_at.to_time,
                                  end: booking.scheduled_at.to_time + duration_minutes.minutes
                                }
                              end
    
    # Get custom availabilities for future dates
    future_custom_availabilities = custom_availabilities
                                     .where("date >= ?", Date.current)
                                     .order(:date, :start_time)
                                     .to_a
    
    # Get regular availabilities grouped by day of week
    regular_availabilities = availabilities.order(:day_of_week, :start_time).to_a
    return nil if regular_availabilities.empty? && future_custom_availabilities.empty?
    
    # Start from today
    start_date = Date.current
    current_time = Time.current
    
    # Check up to 30 days ahead
    (0..30).each do |day_offset|
      check_date = start_date + day_offset.days
      day_of_week = check_date.wday == 0 ? 6 : check_date.wday - 1 # Convert to Monday=0 format
      
      # Check if there's a custom availability for this date
      custom_for_date = future_custom_availabilities.select { |ca| ca.date == check_date }
      
      day_availabilities = if custom_for_date.any?
        # Use custom availabilities (they override regular ones)
        custom_for_date
      else
        # Use regular availabilities for this day of week
        regular_availabilities.select { |a| a.day_of_week == day_of_week }
      end
      
      next if day_availabilities.empty?
      
      # Check each availability slot for this day
      day_availabilities.each do |availability|
        # Convert to datetime for this specific date
        slot_start = Time.zone.parse("#{check_date} #{availability.start_time.strftime('%H:%M')}")
        slot_end = Time.zone.parse("#{check_date} #{availability.end_time.strftime('%H:%M')}")
        
        # Skip if this slot is in the past (for today)
        next if slot_start < current_time
        
        # Check if this slot conflicts with existing bookings
        slot_conflicts = conflicting_bookings.any? do |booking_range|
          # Check for overlap: slot starts before booking ends AND slot ends after booking starts
          slot_start < booking_range[:end] && slot_end > booking_range[:start]
        end
        
        unless slot_conflicts
          return {
            datetime: slot_start,
            date: check_date,
            time: availability.start_time
          }
        end
      end
    end
    
    nil # No availability found
  end
  
  # Format the next availability for display
  def formatted_next_availability
    return nil unless (next_avail = next_availability)
    
    date = next_avail[:date]
    time = next_avail[:time]
    
    today = Date.current
    tomorrow = today + 1.day
    
    if date == today
      "Aujourd'hui #{time.strftime('%H:%M')}"
    elsif date == tomorrow
      "Demain #{time.strftime('%H:%M')}"
    else
      day_names = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
      month_names = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre']
      "#{day_names[date.wday == 0 ? 6 : date.wday - 1]} #{date.day} #{month_names[date.month - 1]} #{time.strftime('%H:%M')}"
    end
  end
  
  private
  
  def set_default_role
    self.role ||= "Client"
  end
  
  def set_default_status
    # If status is already explicitly set, don't override it
    return if status.present?
    
    # By default, status is inactive
    # It will be set to active in controllers when appropriate:
    # - admin/users#create: always active
    # - users/registrations#create: active for clients, inactive for professionals
    self.status = "inactive"
  end
  
  def normalize_role
    return if role.blank?
    
    # Normalize role to proper case (first letter uppercase, rest lowercase)
    normalized = normalize_role_value(role)
    self.role = normalized if normalized != role
  end
  
  def normalize_role_value(value)
    return value if value.blank?
    
    normalized = value.to_s.downcase.strip
    case normalized
    when "client"
      "Client"
    when "professional"
      "Professional"
    when "admin", "administrateur"
      "Admin"
    else
      value # Return original value if not recognized
    end
  end
  
  def send_professional_welcome_email
    UserMailer.professional_welcome_email(self).deliver_later
  end
end
