import { Controller } from "@hotwired/stimulus"

// Simple modal controller
export default class extends Controller {
  connect() {
    // Don't auto-show modal on connect
    // Modal is shown/hidden by event-modal controller or global function
  }

  disconnect() {
    // Restore body scrolling when controller is removed
    document.body.style.overflow = ''
  }

  open(event) {
    // Show modal
    this.element.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
  }

  close(event) {
    // Hide modal
    this.element.classList.add('hidden')
    document.body.style.overflow = ''
  }

  closeWithKeyboard(event) {
    // Close on Escape key
    if (event.key === "Escape") {
      this.close(event)
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
