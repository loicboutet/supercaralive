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
