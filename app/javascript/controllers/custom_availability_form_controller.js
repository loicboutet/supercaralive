import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "slotsContainer"]

  connect() {
    // Initialize with one empty slot if form is shown
    if (!this.hasFormTarget || this.formTarget.classList.contains("hidden")) {
      return
    }
    this.addSlot()
  }

  showForm(event) {
    event.preventDefault()
    if (this.hasFormTarget) {
      this.formTarget.classList.remove("hidden")
      // Add initial slot if container is empty
      if (this.slotsContainerTarget.children.length === 0) {
        this.addSlot()
      }
    }
  }

  hideForm(event) {
    event.preventDefault()
    if (this.hasFormTarget) {
      this.formTarget.classList.add("hidden")
      // Clear slots when hiding
      this.slotsContainerTarget.innerHTML = ""
    }
  }

  addSlot(event) {
    if (event) {
      event.preventDefault()
    }
    
    const slotIndex = this.slotsContainerTarget.children.length
    const slotHtml = `
      <div class="flex items-center gap-4 p-4 bg-white rounded-lg border border-gray-300" data-slot-index="${slotIndex}">
        <div class="flex-1">
          <label class="block text-sm font-medium text-gray-700 mb-1">Heure de début</label>
          <input type="time" 
                 name="custom_availabilities[][start_time]" 
                 required
                 class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-hero focus:border-transparent">
        </div>
        <div class="flex-1">
          <label class="block text-sm font-medium text-gray-700 mb-1">Heure de fin</label>
          <input type="time" 
                 name="custom_availabilities[][end_time]" 
                 required
                 class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-hero focus:border-transparent">
        </div>
        <div class="flex items-end">
          <button type="button" 
                  data-action="click->custom-availability-form#removeSlot"
                  data-slot-index="${slotIndex}"
                  class="bg-red-500 hover:bg-red-600 text-white px-3 py-2 rounded-lg font-medium">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>
      </div>
    `
    
    this.slotsContainerTarget.insertAdjacentHTML("beforeend", slotHtml)
  }

  removeSlot(event) {
    event.preventDefault()
    const slotIndex = event.currentTarget.dataset.slotIndex
    const slotElement = this.slotsContainerTarget.querySelector(`[data-slot-index="${slotIndex}"]`)
    if (slotElement) {
      slotElement.remove()
    }
  }
}

