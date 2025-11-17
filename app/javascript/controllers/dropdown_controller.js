import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    this.hideOnClickOutside = this.hide.bind(this)
  }

  disconnect() {
    document.removeEventListener('click', this.hideOnClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    
    if (this.menuTarget.classList.contains('hidden')) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.menuTarget.classList.remove('hidden')
    
    // Add click listener to close when clicking outside
    setTimeout(() => {
      document.addEventListener('click', this.hideOnClickOutside)
    }, 10)
  }

  hide(event) {
    // Don't hide if clicking inside the menu
    if (event && this.element.contains(event.target)) {
      return
    }
    
    this.menuTarget.classList.add('hidden')
    document.removeEventListener('click', this.hideOnClickOutside)
  }
}
