import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "dropdown", "option", "selectedText", "hiddenInput", "chevron"]
  static values = {
    selectedId: String,
    selectedName: String
  }

  connect() {
    this.close()
    // Set initial selected value if provided
    if (this.selectedIdValue && this.selectedNameValue) {
      this.updateSelected(this.selectedIdValue, this.selectedNameValue)
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  select(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const option = event.currentTarget
    const serviceId = option.dataset.serviceId
    const serviceName = option.dataset.serviceName
    
    this.updateSelected(serviceId, serviceName)
    this.close()
    
    // Trigger change event on hidden input for form submission
    if (this.hasHiddenInputTarget) {
      this.hiddenInputTarget.value = serviceId
      this.hiddenInputTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }
  }

  updateSelected(id, name) {
    this.selectedIdValue = id
    this.selectedNameValue = name
    
    if (this.hasSelectedTextTarget) {
      this.selectedTextTarget.textContent = name || "Sélectionnez un service"
    }
    
    // Update active state of options
    this.optionTargets.forEach(option => {
      if (option.dataset.serviceId === id) {
        option.classList.add("bg-blue-50", "border-blue-hero")
        option.classList.remove("border-gray-200")
      } else {
        option.classList.remove("bg-blue-50", "border-blue-hero")
        option.classList.add("border-gray-200")
      }
    })
  }

  open() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.remove("hidden")
      this.buttonTarget.classList.add("ring-2", "ring-red-hero")
      // Rotate chevron
      if (this.hasChevronTarget) {
        this.chevronTarget.classList.add("transform", "rotate-180")
      }
    }
  }

  close() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add("hidden")
      this.buttonTarget.classList.remove("ring-2", "ring-red-hero")
      // Reset chevron
      if (this.hasChevronTarget) {
        this.chevronTarget.classList.remove("transform", "rotate-180")
      }
    }
  }

  isOpen() {
    return this.hasDropdownTarget && !this.dropdownTarget.classList.contains("hidden")
  }

  // Close dropdown when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}

