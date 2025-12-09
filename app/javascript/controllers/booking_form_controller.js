import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booking-form"
export default class extends Controller {
  static targets = ["vehicleSelect", "mileageInput", "professionalSelect", "serviceInput", "calendarContainer", "infoMessage"]
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
    
    // Check initial state and update display
    this.updateCalendarVisibility()
    
    // Listen to service input changes (triggered by service-select controller)
    if (this.hasServiceInputTarget) {
      this.serviceInputTarget.addEventListener('change', () => {
        this.updateCalendarVisibility()
      })
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
    const url = new URL(window.location.href)
    
    if (professionalId) {
      // Reload the page with the professional_id to load professional services
      url.searchParams.set('professional_id', professionalId)
    } else {
      // Remove professional_id from URL if deselected
      url.searchParams.delete('professional_id')
    }
    
    // Update calendar visibility before reload
    this.updateCalendarVisibility()
    
    window.location.href = url.toString()
  }
  
  updateCalendarVisibility() {
    // Check if professional is selected (either from select or hidden field)
    let hasProfessional = false
    if (this.hasProfessionalSelectTarget) {
      const professionalValue = this.professionalSelectTarget.value
      hasProfessional = professionalValue && professionalValue !== '' && professionalValue !== null
    }
    
    // Check if service is selected
    const hasService = this.hasServiceInputTarget && this.serviceInputTarget.value && this.serviceInputTarget.value !== ''
    
    const bothSelected = hasProfessional && hasService
    
    // Show/hide calendar container
    if (this.hasCalendarContainerTarget) {
      if (bothSelected) {
        this.calendarContainerTarget.classList.remove('hidden')
      } else {
        this.calendarContainerTarget.classList.add('hidden')
      }
    }
    
    // Show/hide info message
    if (this.hasInfoMessageTarget) {
      if (bothSelected) {
        this.infoMessageTarget.classList.add('hidden')
      } else {
        this.infoMessageTarget.classList.remove('hidden')
      }
    }
  }

  professionalServiceChanged(event) {
    // Update calendar visibility first
    this.updateCalendarVisibility()
    
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

