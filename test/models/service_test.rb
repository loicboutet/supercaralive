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
require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
