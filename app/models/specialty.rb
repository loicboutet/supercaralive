# == Schema Information
#
# Table name: specialties
# Database name: primary
#
#  id         :integer          not null, primary key
#  icon       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Specialty < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :icon, presence: true

  # Associations
  has_and_belongs_to_many :users
end
