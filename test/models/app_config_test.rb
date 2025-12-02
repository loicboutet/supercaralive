# == Schema Information
#
# Table name: app_configs
# Database name: primary
#
#  id               :integer          not null, primary key
#  address          :text
#  contact_email    :string
#  contact_phone    :string
#  opening_hours    :text
#  privacy_policy   :text
#  terms_of_service :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

class AppConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
