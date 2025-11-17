# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                            :integer          not null, primary key
#  admin_approval_note           :text
#  cgu_accepted                  :boolean          default(FALSE), not null
#  company_name                  :string
#  display_complete_name         :boolean          default(FALSE), not null
#  email                         :string           default(""), not null
#  encrypted_password            :string           default(""), not null
#  first_name                    :string
#  intervention_zone             :string
#  last_name                     :string
#  location                      :string
#  maintenance_reminders_enabled :boolean          default(TRUE), not null
#  phone_number                  :string
#  professional_presentation     :text
#  remember_created_at           :datetime
#  reset_password_sent_at        :datetime
#  reset_password_token          :string
#  role                          :string           default("client"), not null
#  siret                         :string
#  status                        :string           default("active")
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
