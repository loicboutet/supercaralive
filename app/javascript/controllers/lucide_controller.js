import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lucide"
// Initializes Lucide icons globally
export default class extends Controller {
  connect() {
    this.initializeIcons()
  }

  initializeIcons() {
    if (typeof lucide !== 'undefined') {
      lucide.createIcons()
    }
  }
}

