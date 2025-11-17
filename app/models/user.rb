# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                     :integer          not null, primary key
#  cgu_accepted           :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  location               :string
#  phone_number           :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("client"), not null
#  status                 :string           default("active")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
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
  
  # Set default role and status before validation
  before_validation :set_default_role, on: :create
  before_validation :set_default_status, on: :create
  before_validation :normalize_role
  
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
  
  private
  
  def set_default_role
    self.role ||= "Client"
  end
  
  def set_default_status
    self.status ||= "active"
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
end
