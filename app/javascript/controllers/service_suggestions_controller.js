import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="service-suggestions"
export default class extends Controller {
  static targets = ["serviceCheckbox", "priceInput", "durationInput", "suggestedPrice", "suggestedDuration", "serviceNameInput", "serviceLabel"]
  static values = {
    services: Object
  }

  connect() {
    this.updateSuggestions()
    this.updateServiceSelection()
    // Listen to checkbox changes
    this.serviceCheckboxTargets.forEach(checkbox => {
      checkbox.addEventListener('change', () => {
        this.handleServiceSelection(checkbox)
        this.updateSuggestions()
      })
    })
  }

  serviceChanged(event) {
    this.handleServiceSelection(event.target)
    this.updateSuggestions()
  }

  handleServiceSelection(checkedCheckbox) {
    const isChecked = checkedCheckbox.checked
    
    if (isChecked) {
      // Uncheck all other checkboxes
      this.serviceCheckboxTargets.forEach(checkbox => {
        if (checkbox !== checkedCheckbox) {
          checkbox.checked = false
          this.updateLabelState(checkbox, false)
        }
      })
      // Update the checked checkbox's label state
      this.updateLabelState(checkedCheckbox, true)
      
      // Fill service name automatically
      if (this.hasServiceNameInputTarget) {
        const serviceName = checkedCheckbox.dataset.serviceName
        if (serviceName) {
          // Only fill if the field is empty or matches a previous auto-filled value
          const currentValue = this.serviceNameInputTarget.value.trim()
          if (currentValue === "" || this.wasAutoFilled) {
            this.serviceNameInputTarget.value = serviceName
            this.wasAutoFilled = true
          }
        }
      }
    } else {
      // If unchecked, enable all checkboxes
      this.serviceCheckboxTargets.forEach(checkbox => {
        this.updateLabelState(checkbox, false)
      })
      this.wasAutoFilled = false
    }
  }

  updateLabelState(checkbox, isSelected) {
    const label = checkbox.closest('label')
    if (label) {
      if (isSelected) {
        label.classList.remove('opacity-50', 'cursor-not-allowed')
        label.classList.add('bg-red-50')
        checkbox.disabled = false
      } else {
        // Check if any other checkbox is selected
        const hasOtherSelected = Array.from(this.serviceCheckboxTargets).some(cb => cb !== checkbox && cb.checked)
        if (hasOtherSelected) {
          label.classList.add('opacity-50', 'cursor-not-allowed')
          label.classList.remove('bg-red-50')
          checkbox.disabled = true
        } else {
          label.classList.remove('opacity-50', 'cursor-not-allowed', 'bg-red-50')
          checkbox.disabled = false
        }
      }
    }
  }

  updateServiceSelection() {
    // Initialize state on page load
    const checkedCheckboxes = this.serviceCheckboxTargets.filter(cb => cb.checked)
    
    if (checkedCheckboxes.length > 0) {
      // If multiple are checked, keep only the first one
      const firstChecked = checkedCheckboxes[0]
      checkedCheckboxes.slice(1).forEach(cb => {
        cb.checked = false
      })
      this.handleServiceSelection(firstChecked)
    } else {
      // Enable all if none are checked
      this.serviceCheckboxTargets.forEach(checkbox => {
        this.updateLabelState(checkbox, false)
      })
    }
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

