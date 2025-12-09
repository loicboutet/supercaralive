namespace :services do
  desc "Update popular status for all services based on completed bookings"
  task update_popular: :environment do
    puts "Updating popular status for all services..."
    Service.update_popular_services!
    popular_count = Service.where(popular: true).count
    puts "Done! #{popular_count} service(s) are now marked as popular."
  end
end

