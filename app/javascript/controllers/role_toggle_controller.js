import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clientFields", "professionalFields", "professionalInfo", "roleCard", "roleRadio"]

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

    // Toggle fields visibility
    if (role === 'client') {
      this.clientFieldsTarget.classList.remove('hidden')
      this.professionalFieldsTarget.classList.add('hidden')
      this.professionalInfoTarget.classList.add('hidden')
    } else {
      this.clientFieldsTarget.classList.add('hidden')
      this.professionalFieldsTarget.classList.remove('hidden')
      this.professionalInfoTarget.classList.remove('hidden')
    }
  }
}



