import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirm"
export default class extends Controller {
  static values = {
    message: { type: String, default: "Êtes-vous sûr ?" }
  }

  confirm(event) {
    if (!window.confirm(this.messageValue)) {
      event.preventDefault()
      event.stopPropagation()
      return false
    }
  }
}





