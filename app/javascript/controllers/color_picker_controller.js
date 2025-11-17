import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="color-picker"
export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    this.updatePreview()
  }

  updatePreview() {
    const color = this.inputTarget.value
    if (this.hasPreviewTarget) {
      this.previewTarget.style.backgroundColor = color
    }
  }

  colorChanged() {
    this.updatePreview()
  }
}
