# == Schema Information
#
# Table name: professional_documents
# Database name: primary
#
#  id         :integer          not null, primary key
#  comments   :text
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_professional_documents_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require "test_helper"

class ProfessionalDocumentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
