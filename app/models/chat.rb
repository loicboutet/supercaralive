# == Schema Information
#
# Table name: chats
# Database name: primary
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :integer          not null
#
# Indexes
#
#  index_chats_on_booking_id  (booking_id) UNIQUE
#
# Foreign Keys
#
#  booking_id  (booking_id => bookings.id)
#
class Chat < ApplicationRecord
  belongs_to :booking
  has_many :chat_messages, dependent: :destroy

  validates :booking_id, uniqueness: true
end

