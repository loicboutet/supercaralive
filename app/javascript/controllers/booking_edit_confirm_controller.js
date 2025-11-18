import { Controller } from "@hotwired/stimulus"

// Controller to show confirmation modal when editing an accepted booking
export default class extends Controller {
  static targets = ["modal", "form", "confirmButton", "cancelButton"]
  static values = {
    isAccepted: Boolean
  }

  connect() {
    // Flag to track if user confirmed the submission
    this.confirmed = false
  }

  submit(event) {
    // If already confirmed, let the form submit normally
    if (this.confirmed) {
      this.confirmed = false // Reset flag
      return
    }

    // Only show modal if booking is accepted
    if (this.isAcceptedValue) {
      event.preventDefault()
      event.stopPropagation()
      this.openModal()
    }
    // Otherwise, let the form submit normally
  }

  openModal() {
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  closeModal() {
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  confirmSubmit() {
    // Set flag to allow submission
    this.confirmed = true
    this.closeModal()
    // Submit the form programmatically
    this.formTarget.requestSubmit()
  }

  cancelSubmit() {
    this.closeModal()
  }

  closeWithKeyboard(event) {
    // Close on Escape key
    if (event.key === "Escape") {
      this.closeModal()
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}

