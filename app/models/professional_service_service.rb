# == Schema Information
#
# Table name: professional_service_services
# Database name: primary
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  professional_service_id :integer          not null
#  service_id              :integer          not null
#
# Indexes
#
#  index_prof_service_services_unique                              (professional_service_id,service_id) UNIQUE
#  index_professional_service_services_on_professional_service_id  (professional_service_id)
#  index_professional_service_services_on_service_id               (service_id)
#
# Foreign Keys
#
#  professional_service_id  (professional_service_id => professional_services.id)
#  service_id               (service_id => services.id)
#
class ProfessionalServiceService < ApplicationRecord
  belongs_to :professional_service
  belongs_to :service

  validates :professional_service_id, uniqueness: { scope: :service_id }
end


