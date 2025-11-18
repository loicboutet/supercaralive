class CreateChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
    
    add_index :chat_messages, :created_at
  end
end
