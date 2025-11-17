import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="icon-picker"
export default class extends Controller {
  static targets = ["input", "preview", "selector"]

  connect() {
    // Initialize Lucide icons when controller connects
    if (typeof lucide !== 'undefined') {
      lucide.createIcons()
    }
  }

  // Update preview when typing in the input field
  updatePreview(event) {
    const iconName = event.target.value.trim()
    if (iconName && this.hasPreviewTarget) {
      this.previewTarget.setAttribute('data-lucide', iconName)
      if (typeof lucide !== 'undefined') {
        lucide.createIcons()
      }
    }
  }

  // Handle icon selection from the grid
  selectIcon(event) {
    event.preventDefault()
    const iconName = event.currentTarget.getAttribute('data-icon-name')
    
    // Update input field
    if (this.hasInputTarget) {
      this.inputTarget.value = iconName
    }
    
    // Update preview
    if (this.hasPreviewTarget) {
      this.previewTarget.setAttribute('data-lucide', iconName)
      if (typeof lucide !== 'undefined') {
        lucide.createIcons()
      }
    }
    
    // Visual feedback - remove selection from all buttons
    this.selectorTargets.forEach(btn => {
      btn.classList.remove('border-purple-600', 'bg-purple-50')
    })
    
    // Add selection to clicked button
    event.currentTarget.classList.add('border-purple-600', 'bg-purple-50')
  }

  // Reinitialize icons (useful for Turbo navigation)
  reinitializeIcons() {
    if (typeof lucide !== 'undefined') {
      lucide.createIcons()
    }
  }
}
