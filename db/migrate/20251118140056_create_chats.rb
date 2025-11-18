class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.references :booking, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
