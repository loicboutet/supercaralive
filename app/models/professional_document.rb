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
class ProfessionalDocument < ApplicationRecord
  belongs_to :user
  
  # Active Storage attachment
  has_one_attached :file

  validates :name, presence: true
  validates :user_id, presence: true
  
  # Ensure file is attached on create
  validate :file_must_be_attached, on: :create
  
  # Ensure user is a professional
  validate :user_must_be_professional

  private

  def file_must_be_attached
    unless file.attached?
      errors.add(:file, "doit être fourni")
    end
  end

  def user_must_be_professional
    if user.present? && !user.professional?
      errors.add(:user, "must be a professional")
    end
  end
end
