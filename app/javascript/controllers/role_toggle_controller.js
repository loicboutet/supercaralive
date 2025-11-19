import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clientFields", "professionalFields", "professionalInfo", "roleCard", "roleRadio", "firstNameField", "lastNameField"]

  connect() {
    // Set initial state based on checked radio
    this.updateFields()
  }

  toggle(event) {
    this.updateFields()
  }

  updateFields() {
    const checkedRadio = this.roleRadioTargets.find(radio => radio.checked)
    if (!checkedRadio) return

    const role = checkedRadio.dataset.role

    // Update card borders
    this.roleCardTargets.forEach(card => {
      card.classList.remove('border-blue-hero', 'border-red-hero', 'border-4')
      card.classList.add('border-2', 'border-gray-200')
    })

    const selectedCard = checkedRadio.closest('.role-card')
    if (selectedCard) {
      selectedCard.classList.remove('border-2', 'border-gray-200')
      selectedCard.classList.add('border-4', role === 'client' ? 'border-blue-hero' : 'border-red-hero')
    }

    // Toggle fields visibility and required attribute
    if (role === 'client') {
      this.clientFieldsTarget.classList.remove('hidden')
      this.professionalFieldsTarget.classList.add('hidden')
      this.professionalInfoTarget.classList.add('hidden')
      
      // Make first_name and last_name required for clients
      if (this.hasFirstNameFieldTarget) {
        this.firstNameFieldTarget.setAttribute('required', 'required')
      }
      if (this.hasLastNameFieldTarget) {
        this.lastNameFieldTarget.setAttribute('required', 'required')
      }
    } else {
      this.clientFieldsTarget.classList.add('hidden')
      this.professionalFieldsTarget.classList.remove('hidden')
      this.professionalInfoTarget.classList.remove('hidden')
      
      // Remove required attribute for professionals
      if (this.hasFirstNameFieldTarget) {
        this.firstNameFieldTarget.removeAttribute('required')
      }
      if (this.hasLastNameFieldTarget) {
        this.lastNameFieldTarget.removeAttribute('required')
      }
    }
  }
}



