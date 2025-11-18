class CreateJoinTableSpecialtiesUsers < ActiveRecord::Migration[8.0]
  def change
    create_join_table :specialties, :users do |t|
      t.index [:specialty_id, :user_id]
      t.index [:user_id, :specialty_id]
    end
  end
end
