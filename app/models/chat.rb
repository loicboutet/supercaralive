class Chat < ApplicationRecord
  belongs_to :booking
  has_many :chat_messages, dependent: :destroy

  validates :booking_id, uniqueness: true
end

