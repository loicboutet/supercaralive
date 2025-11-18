namespace :geocode do
  desc "Geocode all professionals with location but no coordinates"
  task professionals: :environment do
    professionals = User.where(role: "Professional")
                        .where.not(location: [nil, ""])
                        .where(latitude: nil)
                        .or(User.where(role: "Professional")
                                .where.not(location: [nil, ""])
                                .where(longitude: nil))
    
    total = professionals.count
    puts "Found #{total} professionals to geocode"
    
    geocoded = 0
    failed = 0
    
    professionals.find_each do |professional|
      begin
        professional.geocode
        if professional.save
          geocoded += 1
          puts "✓ Geocoded: #{professional.location} (#{professional.email})"
        else
          failed += 1
          puts "✗ Failed to save: #{professional.location} (#{professional.email})"
        end
      rescue => e
        failed += 1
        puts "✗ Error geocoding #{professional.location} (#{professional.email}): #{e.message}"
      end
      
      # Be nice to the geocoding API
      sleep(1) if geocoded % 10 == 0
    end
    
    puts "\nCompleted: #{geocoded} geocoded, #{failed} failed out of #{total} total"
  end
end

