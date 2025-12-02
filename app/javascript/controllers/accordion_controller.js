import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "chevron"]

  toggle(event) {
    event.preventDefault()
    const content = this.contentTarget
    const chevron = this.hasChevronTarget ? this.chevronTarget : null
    
    // Toggle content visibility
    content.classList.toggle("hidden")
    
    // Rotate chevron if present
    if (chevron) {
      chevron.classList.toggle("rotate-180")
    }
  }
}

