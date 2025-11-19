class CreateAdminUserIfNotExists < ActiveRecord::Migration[8.0]
  def up
    # Create admin user if it doesn't already exist
    unless User.exists?(email: "admin@5000.dev")
      User.create!(
        email: "admin@5000.dev",
        password: "secret5000",
        password_confirmation: "secret5000",
        role: "Admin",
        status: "active",
        cgu_accepted: true
      )
    end
  end

  def down
    # Optionally remove the admin user on rollback
    # Uncomment the following line if you want to remove the admin user when rolling back
    # User.find_by(email: "admin@5000.dev")&.destroy
  end
end
