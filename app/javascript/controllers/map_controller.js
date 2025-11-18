import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class extends Controller {
  static targets = ["container"]
  static values = {
    location: String,
    radius: Number
  }

  connect() {
    // Wait for Leaflet to be available
    if (typeof L === 'undefined') {
      console.error("Leaflet is not loaded. Make sure the script is included in the layout.")
      return
    }
    this.initMap()
  }

  async initMap() {
    // Default coordinates (Paris center) if geocoding fails
    let lat = 48.8566
    let lon = 2.3522
    let radius = this.hasRadiusValue ? this.radiusValue : 0

    // Geocode the location if provided
    if (this.locationValue) {
      try {
        const coords = await this.geocodeLocation(this.locationValue)
        if (coords) {
          lat = coords.lat
          lon = coords.lon
        }
      } catch (error) {
        console.error("Geocoding error:", error)
      }
    }

    // Get the container element
    const container = this.hasContainerTarget ? this.containerTarget : this.element

    // Initialize the map
    const zoomLevel = radius > 0 ? (radius > 10 ? 11 : 12) : 13
    this.map = L.map(container, {
      zoomControl: true,
      scrollWheelZoom: true
    }).setView([lat, lon], zoomLevel)

    // Add OpenStreetMap tiles (using OSM France tiles like in the guide)
    L.tileLayer('https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(this.map)

    // Add a marker for the location
    const marker = L.marker([lat, lon]).addTo(this.map)
    marker.bindPopup(`<b>${this.locationValue || 'Localisation'}</b>`).openPopup()

    // Draw a circle for the intervention radius
    if (radius > 0) {
      const circle = L.circle([lat, lon], {
        color: '#dc2626', // red-hero color
        fillColor: '#fee2e2', // red-50 color
        fillOpacity: 0.3,
        weight: 2,
        radius: radius * 1000 // Convert km to meters
      }).addTo(this.map)

      // Add radius label (offset slightly from marker)
      const offsetLat = lat + (radius * 0.01) // Offset north
      const radiusLabel = L.marker([offsetLat, lon], {
        icon: L.divIcon({
          className: 'radius-label',
          html: `<div style="background: rgba(220, 38, 38, 0.9); color: white; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; white-space: nowrap; box-shadow: 0 2px 4px rgba(0,0,0,0.2);">Rayon ${radius} km</div>`,
          iconSize: [null, null],
          iconAnchor: [0, 0]
        })
      }).addTo(this.map)

      // Fit map to show the circle with padding
      this.map.fitBounds(circle.getBounds(), { padding: [50, 50] })
    } else {
      // If no radius, just center on the marker
      this.map.setView([lat, lon], 13)
    }
  }

  async geocodeLocation(location) {
    // Use Nominatim API (OpenStreetMap geocoding service)
    // Following the guide's approach with User-Agent
    const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(location)}&limit=1&addressdetails=1`
    
    try {
      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Supercaralive/1.0 (contact@supercaralive.com)' // Required by Nominatim
        }
      })
      
      if (!response.ok) {
        throw new Error('Geocoding failed')
      }
      
      const data = await response.json()
      
      if (data && data.length > 0) {
        return {
          lat: parseFloat(data[0].lat),
          lon: parseFloat(data[0].lon)
        }
      }
    } catch (error) {
      console.error("Geocoding error:", error)
    }
    
    return null
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
