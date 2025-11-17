# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                        :integer          not null, primary key
#  admin_approval_note       :text
#  cgu_accepted              :boolean          default(FALSE), not null
#  company_name              :string
#  email                     :string           default(""), not null
#  encrypted_password        :string           default(""), not null
#  first_name                :string
#  intervention_zone         :string
#  last_name                 :string
#  location                  :string
#  phone_number              :string
#  professional_presentation :text
#  remember_created_at       :datetime
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  role                      :string           default("client"), not null
#  siret                     :string
#  status                    :string           default("active")
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
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
  has_one_attached :profile_photo

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
