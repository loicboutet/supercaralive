import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="service-suggestions"
export default class extends Controller {
  static targets = ["serviceCheckbox", "priceInput", "durationInput", "suggestedPrice", "suggestedDuration"]
  static values = {
    services: Object
  }

  connect() {
    this.updateSuggestions()
    // Listen to checkbox changes
    this.serviceCheckboxTargets.forEach(checkbox => {
      checkbox.addEventListener('change', () => this.updateSuggestions())
    })
  }

  serviceChanged() {
    this.updateSuggestions()
  }

  updateSuggestions() {
    const selectedServices = this.serviceCheckboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => {
        const serviceId = checkbox.value
        // Try both string and number keys
        return this.servicesValue[serviceId] || this.servicesValue[parseInt(serviceId)]
      })
      .filter(service => service !== undefined)

    // Calculate suggested price
    const suggestedPrice = selectedServices.reduce((sum, service) => {
      return sum + (parseFloat(service.suggested_price) || 0)
    }, 0)

    // Calculate suggested duration
    const suggestedDuration = selectedServices.reduce((sum, service) => {
      return sum + (parseInt(service.estimated_duration) || 0)
    }, 0)

    // Update display
    if (this.hasSuggestedPriceTarget) {
      this.suggestedPriceTarget.textContent = suggestedPrice > 0 
        ? `Prix suggéré : ${suggestedPrice.toFixed(2)} €` 
        : ""
    }

    if (this.hasSuggestedDurationTarget) {
      this.suggestedDurationTarget.textContent = suggestedDuration > 0 
        ? `Durée suggérée : ${suggestedDuration} min` 
        : ""
    }

    // Optionally pre-fill if empty
    if (this.hasPriceInputTarget && this.priceInputTarget.value === "") {
      this.priceInputTarget.value = suggestedPrice > 0 ? suggestedPrice.toFixed(2) : ""
    }

    if (this.hasDurationInputTarget && this.durationInputTarget.value === "") {
      this.durationInputTarget.value = suggestedDuration > 0 ? suggestedDuration : ""
    }
  }
}

