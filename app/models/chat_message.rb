# == Schema Information
#
# Table name: chat_messages
# Database name: primary
#
#  id         :integer          not null, primary key
#  content    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  chat_id    :integer          not null
#  user_id    :integer
#
# Indexes
#
#  index_chat_messages_on_chat_id     (chat_id)
#  index_chat_messages_on_created_at  (created_at)
#  index_chat_messages_on_user_id     (user_id)
#
# Foreign Keys
#
#  chat_id  (chat_id => chats.id)
#  user_id  (user_id => users.id)
#
class ChatMessage < ApplicationRecord
  belongs_to :chat
  belongs_to :user, optional: true

  validates :content, presence: true, length: { maximum: 1000 }

  # Callback Turbo Stream pour diffuser les nouveaux messages
  after_create_commit :broadcast_message

  scope :recent, -> { order(:created_at) }

  def system?
    user.nil?
  end

  def formatted_time
    if created_at.today?
      created_at.strftime("%H:%M")
    elsif created_at.to_date == Date.yesterday
      "Hier à #{created_at.strftime("%H:%M")}"
    else
      created_at.strftime("%d/%m/%Y à %H:%M")
    end
  end

  private

  def broadcast_message
    # Diffuser le nouveau message à tous les utilisateurs du chat
    # Le partial affiche simplement qui a créé le message (pas de contexte)
    # Le scroll automatique est géré par le stimulus controller via MutationObserver
    broadcast_append_to(
      "chat_#{chat.id}",
      target: "messages",
      partial: "chat_messages/message",
      locals: { message: self }
    )
  end
end

