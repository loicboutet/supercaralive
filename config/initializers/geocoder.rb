Geocoder.configure(
  # Use Nominatim (OpenStreetMap) as the geocoding service
  lookup: :nominatim,
  
  # Nominatim API endpoint
  nominatim: {
    timeout: 5,
    user_agent: "SuperCarAlive App"
  },
  
  # Timeout for geocoding requests
  timeout: 5,
  
  # Units for distance calculations
  units: :km,
  
  # Cache configuration (optional, can be added later)
  # cache: Redis.new,
  # cache_prefix: "geocoder:"
)

