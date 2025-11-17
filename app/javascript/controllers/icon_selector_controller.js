import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="icon-selector"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    // Default icons to display
    this.defaultIcons = [
      "🔧", "⚙️", "🔨", "✨", "⭐", "🚗", "🛠️", "💧", "🧽", "🔩"
    ]
  }

  selectIcon(event) {
    const icon = event.currentTarget.dataset.icon
    if (this.hasInputTarget) {
      this.inputTarget.value = icon
      // Optional: Add visual feedback
      this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    }
  }
}

