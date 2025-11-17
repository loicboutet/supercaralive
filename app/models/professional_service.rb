# == Schema Information
#
# Table name: professional_services
# Database name: primary
#
#  id               :integer          not null, primary key
#  active           :boolean          default(TRUE), not null
#  duration_minutes :integer
#  name             :string           not null
#  price            :decimal(8, 2)    not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer          not null
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

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true
  validate :must_have_at_least_one_service

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :for_user, ->(user) { where(user: user) }

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

  private

  def must_have_at_least_one_service
    if service_ids.blank? && services.empty?
      errors.add(:base, "Vous devez sélectionner au moins un service")
    end
  end
end

