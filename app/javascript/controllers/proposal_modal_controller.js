import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
  }

  close(event) {
    event.preventDefault()
    this.modalTarget.classList.add("hidden")
  }

  // Close modal when clicking outside
  closeOnOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.close(event)
    }
  }

  connect() {
    // Add click handler on the modal backdrop
    this.modalTarget.addEventListener("click", this.closeOnOutsideClick.bind(this))
  }

  disconnect() {
    this.modalTarget.removeEventListener("click", this.closeOnOutsideClick.bind(this))
  }
}
