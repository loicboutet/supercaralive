import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booking-form"
export default class extends Controller {
  static targets = ["vehicleSelect", "mileageInput"]
  static values = {
    vehicles: Object
  }

  connect() {
    // Set initial mileage if vehicle is already selected
    if (this.hasVehicleSelectTarget && this.hasMileageInputTarget) {
      const selectedVehicleId = this.vehicleSelectTarget.value
      if (selectedVehicleId) {
        this.updateMileage(selectedVehicleId)
      }
    }
  }

  vehicleChanged(event) {
    const vehicleId = event.target.value
    if (vehicleId && this.hasMileageInputTarget) {
      this.updateMileage(vehicleId)
    }
  }

  updateMileage(vehicleId) {
    const vehicle = this.vehiclesValue[vehicleId]
    if (vehicle && vehicle.mileage && vehicle.mileage > 0) {
      this.mileageInputTarget.value = vehicle.mileage
    }
  }

  professionalChanged(event) {
    const professionalId = event.target.value
    if (professionalId) {
      // Reload the page with the professional_id to load professional services
      const url = new URL(window.location.href)
      url.searchParams.set('professional_id', professionalId)
      window.location.href = url.toString()
    }
  }

  professionalServiceChanged(event) {
    // This will be handled by booking-calendar controller
    // Just update the calendar controller's professional_service_id value
    const calendarController = this.application.getControllerForElementAndIdentifier(
      this.element,
      'booking-calendar'
    )
    if (calendarController) {
      calendarController.professionalServiceIdValue = event.target.value
      calendarController.professionalServiceChanged()
    }
  }
}

