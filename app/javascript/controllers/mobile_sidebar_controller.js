import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-sidebar"
export default class extends Controller {
  static targets = ["sidebar", "overlay"]
  static values = { open: Boolean }

  connect() {
    // Close sidebar when clicking on links inside
    this.sidebarTarget.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        setTimeout(() => this.close(), 100)
      })
    })
  }

  toggle() {
    if (this.openValue) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.sidebarTarget.classList.remove('-translate-x-full')
    this.overlayTarget.classList.remove('hidden')
    document.body.classList.add('overflow-hidden')
    this.openValue = true
  }

  close() {
    this.sidebarTarget.classList.add('-translate-x-full')
    this.overlayTarget.classList.add('hidden')
    document.body.classList.remove('overflow-hidden')
    this.openValue = false
  }
}

