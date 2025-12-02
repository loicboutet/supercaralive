import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // The controller is on the modal element itself, so this.element is the modal
    this.modalElement = this.element
  }

  open(event) {
    if (event) {
      event.preventDefault()
    }
    
    // Clear form
    const textarea = this.modalElement.querySelector('textarea[name="notes"]')
    if (textarea) {
      textarea.value = ""
    }
    
    // Show modal
    this.modalElement.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    
    // Focus on textarea
    if (textarea) {
      setTimeout(() => textarea.focus(), 100)
    }
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }
    
    this.modalElement.classList.add("hidden")
    document.body.style.overflow = ""
  }

  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close(event)
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  submit(event) {
    // Validate notes are present
    const textarea = this.modalElement.querySelector('textarea[name="notes"]')
    
    if (textarea && !textarea.value.trim()) {
      event.preventDefault()
      event.stopPropagation()
      alert("Veuillez renseigner les notes avant d'envoyer la demande.")
      return false
    }
    // Form will submit normally
  }
}
