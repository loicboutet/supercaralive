import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="service-category-dropdown"
export default class extends Controller {
  static targets = ["toggle", "content", "icon"]

  connect() {
    // Check if dropdown should be open by default (has selected services or content is already visible)
    const hasSelectedServices = this.element.querySelector('input[type="checkbox"]:checked')
    const isAlreadyOpen = this.hasContentTarget && !this.contentTarget.classList.contains("hidden")
    
    if (hasSelectedServices || isAlreadyOpen) {
      this.open()
    } else {
      // Ensure icon is in correct state
      if (this.hasIconTarget) {
        this.iconTarget.classList.remove("rotate-180")
        this.iconTarget.classList.add("rotate-0")
      }
    }
  }

  toggle() {
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("hidden")
    }
    if (this.hasIconTarget) {
      this.iconTarget.classList.remove("rotate-0")
      this.iconTarget.classList.add("rotate-180")
    }
  }

  close() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add("hidden")
    }
    if (this.hasIconTarget) {
      this.iconTarget.classList.remove("rotate-180")
      this.iconTarget.classList.add("rotate-0")
    }
  }

  isOpen() {
    return this.hasContentTarget && !this.contentTarget.classList.contains("hidden")
  }
}

