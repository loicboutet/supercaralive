import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="document-upload"
export default class extends Controller {
  static targets = ["fileInput", "submitButton", "nameInput"]

  connect() {
    // Validate on page load
    this.validateForm()
    
    // Listen to name input changes
    if (this.hasNameInputTarget) {
      this.nameInputTarget.addEventListener('input', () => this.validateForm())
    }
  }

  fileChanged() {
    this.validateForm()
  }

  nameChanged() {
    this.validateForm()
  }

  validateForm() {
    const hasFile = this.fileInputTarget.files && this.fileInputTarget.files.length > 0
    const hasName = this.hasNameInputTarget && this.nameInputTarget.value.trim().length > 0
    const isValid = hasFile && hasName
    
    if (this.hasSubmitButtonTarget) {
      if (!isValid) {
        this.submitButtonTarget.disabled = true
        this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      } else {
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      }
    }
  }

  submit(event) {
    const hasFile = this.fileInputTarget.files && this.fileInputTarget.files.length > 0
    const hasName = this.hasNameInputTarget && this.nameInputTarget.value.trim().length > 0
    
    if (!hasFile) {
      event.preventDefault()
      event.stopPropagation()
      alert("Veuillez sélectionner un fichier à uploader avant de soumettre le formulaire.")
      this.fileInputTarget.focus()
      return false
    }
    
    if (!hasName) {
      event.preventDefault()
      event.stopPropagation()
      alert("Veuillez remplir le nom du document avant de soumettre le formulaire.")
      if (this.hasNameInputTarget) {
        this.nameInputTarget.focus()
      }
      return false
    }
  }
}

