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
class AppConfig < ApplicationRecord
  # Get or create the singleton instance
  def self.instance
    first_or_create!
  end
end
