import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dismissible"
export default class extends Controller {
  static targets = ["notice", "progressBar"]

  connect() {
    // Start the progress bar animation
    this.startProgressAnimation()
    
    // Auto-dismiss after 10 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 10000)
  }

  disconnect() {
    // Clear timeout if controller is disconnected before auto-dismiss
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  startProgressAnimation() {
    if (this.hasProgressBarTarget) {
      // Set initial state
      this.progressBarTarget.style.width = "100%"
      this.progressBarTarget.style.transition = "width 10s linear"
      
      // Start animation on next frame to ensure transition works
      requestAnimationFrame(() => {
        this.progressBarTarget.style.width = "0%"
      })
    }
  }

  dismiss() {
    // Clear the timeout to prevent double execution
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }

    // Add fade out animation
    this.noticeTarget.style.transition = "opacity 0.3s ease-out, transform 0.3s ease-out"
    this.noticeTarget.style.opacity = "0"
    this.noticeTarget.style.transform = "translateY(-10px)"

    // Remove element after animation
    setTimeout(() => {
      this.noticeTarget.remove()
    }, 300)
  }
}
