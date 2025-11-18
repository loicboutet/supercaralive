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
require "test_helper"

class BookingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
