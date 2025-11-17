import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pricing-toggle"
export default class extends Controller {
  static targets = [
    "servicePricingType",
    "flatRatePriceInput",
    "hourlyRatePriceInput",
    "travelPricingType",
    "travelFlatRateInput",
    "travelPerKmRateInput"
  ]

  connect() {
    // Initialize visibility based on current values
    this.updateServicePricingVisibility()
    this.updateTravelPricingVisibility()
    
    // Enable/disable inputs based on visibility
    this.syncInputStates()
  }

  syncInputStates() {
    // Sync service pricing inputs
    if (this.hasFlatRatePriceInputTarget) {
      const isVisible = !this.flatRatePriceInputTarget.closest(".pricing-field-group")?.classList.contains("hidden")
      if (isVisible) {
        this.flatRatePriceInputTarget.removeAttribute("disabled")
      } else {
        this.flatRatePriceInputTarget.setAttribute("disabled", "disabled")
      }
    }
    
    if (this.hasHourlyRatePriceInputTarget) {
      const isVisible = !this.hourlyRatePriceInputTarget.closest(".pricing-field-group")?.classList.contains("hidden")
      if (isVisible) {
        this.hourlyRatePriceInputTarget.removeAttribute("disabled")
      } else {
        this.hourlyRatePriceInputTarget.setAttribute("disabled", "disabled")
      }
    }
    
    // Sync travel pricing inputs
    if (this.hasTravelFlatRateInputTarget) {
      const isVisible = !this.travelFlatRateInputTarget.closest(".pricing-field-group")?.classList.contains("hidden")
      if (isVisible) {
        this.travelFlatRateInputTarget.removeAttribute("disabled")
      } else {
        this.travelFlatRateInputTarget.setAttribute("disabled", "disabled")
      }
    }
    
    if (this.hasTravelPerKmRateInputTarget) {
      const isVisible = !this.travelPerKmRateInputTarget.closest(".pricing-field-group")?.classList.contains("hidden")
      if (isVisible) {
        this.travelPerKmRateInputTarget.removeAttribute("disabled")
      } else {
        this.travelPerKmRateInputTarget.setAttribute("disabled", "disabled")
      }
    }
  }

  servicePricingTypeChanged() {
    this.updateServicePricingVisibility()
    this.syncInputStates()
  }

  travelPricingTypeChanged() {
    this.updateTravelPricingVisibility()
    this.syncInputStates()
  }

  updateServicePricingVisibility() {
    if (!this.hasServicePricingTypeTarget) return
    
    const pricingType = this.servicePricingTypeTarget.value
    
    if (pricingType === "flat_rate") {
      this.showFlatRateInput()
      this.hideHourlyRateInput()
    } else if (pricingType === "hourly_rate") {
      this.hideFlatRateInput()
      this.showHourlyRateInput()
    } else {
      this.hideFlatRateInput()
      this.hideHourlyRateInput()
    }
  }

  updateTravelPricingVisibility() {
    if (!this.hasTravelPricingTypeTarget) return
    
    const travelPricingType = this.travelPricingTypeTarget.value
    
    if (!travelPricingType || travelPricingType === "") {
      this.hideTravelFlatRateInput()
      this.hideTravelPerKmRateInput()
      return
    }
    
    if (travelPricingType === "flat_rate") {
      this.showTravelFlatRateInput()
      this.hideTravelPerKmRateInput()
    } else if (travelPricingType === "per_km") {
      this.hideTravelFlatRateInput()
      this.showTravelPerKmRateInput()
    }
  }

  showFlatRateInput() {
    if (this.hasFlatRatePriceInputTarget) {
      this.flatRatePriceInputTarget.closest(".pricing-field-group")?.classList.remove("hidden")
      this.flatRatePriceInputTarget.removeAttribute("disabled")
    }
  }

  hideFlatRateInput() {
    if (this.hasFlatRatePriceInputTarget) {
      this.flatRatePriceInputTarget.closest(".pricing-field-group")?.classList.add("hidden")
      this.flatRatePriceInputTarget.setAttribute("disabled", "disabled")
      this.flatRatePriceInputTarget.value = ""
    }
  }

  showHourlyRateInput() {
    if (this.hasHourlyRatePriceInputTarget) {
      this.hourlyRatePriceInputTarget.closest(".pricing-field-group")?.classList.remove("hidden")
      this.hourlyRatePriceInputTarget.removeAttribute("disabled")
    }
  }

  hideHourlyRateInput() {
    if (this.hasHourlyRatePriceInputTarget) {
      this.hourlyRatePriceInputTarget.closest(".pricing-field-group")?.classList.add("hidden")
      this.hourlyRatePriceInputTarget.setAttribute("disabled", "disabled")
      this.hourlyRatePriceInputTarget.value = ""
    }
  }

  showTravelFlatRateInput() {
    if (this.hasTravelFlatRateInputTarget) {
      this.travelFlatRateInputTarget.closest(".pricing-field-group")?.classList.remove("hidden")
      this.travelFlatRateInputTarget.removeAttribute("disabled")
    }
  }

  hideTravelFlatRateInput() {
    if (this.hasTravelFlatRateInputTarget) {
      this.travelFlatRateInputTarget.closest(".pricing-field-group")?.classList.add("hidden")
      this.travelFlatRateInputTarget.setAttribute("disabled", "disabled")
      this.travelFlatRateInputTarget.value = ""
    }
  }

  showTravelPerKmRateInput() {
    if (this.hasTravelPerKmRateInputTarget) {
      this.travelPerKmRateInputTarget.closest(".pricing-field-group")?.classList.remove("hidden")
      this.travelPerKmRateInputTarget.removeAttribute("disabled")
    }
  }

  hideTravelPerKmRateInput() {
    if (this.hasTravelPerKmRateInputTarget) {
      this.travelPerKmRateInputTarget.closest(".pricing-field-group")?.classList.add("hidden")
      this.travelPerKmRateInputTarget.setAttribute("disabled", "disabled")
      this.travelPerKmRateInputTarget.value = ""
    }
  }
}

