import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dayOfWeekInput", "dayName", "startTimeInput", "endTimeInput", "form", "title", "modal"]
  static values = {
    dayOfWeek: Number,
    dayName: String,
    availabilityId: Number,
    startTime: String,
    endTime: String
  }

  open(event) {
    event.preventDefault()
    
    const dayOfWeek = event.currentTarget.dataset.availabilityModalDayOfWeekValue
    const dayName = event.currentTarget.dataset.availabilityModalDayNameValue
    
    // Set form values for new availability
    this.dayOfWeekInputTarget.value = dayOfWeek
    this.dayNameTarget.textContent = dayName
    this.startTimeInputTarget.value = ""
    this.endTimeInputTarget.value = ""
    this.titleTarget.textContent = `Ajouter un créneau - ${dayName}`
    
    // Update form action for create
    const baseUrl = window.location.origin + '/professional/availability_slots'
    this.formTarget.action = baseUrl
    this.formTarget.method = "post"
    
    // Remove method field if exists (for edit mode)
    const methodInput = this.formTarget.querySelector('input[name="_method"]')
    if (methodInput) {
      methodInput.remove()
    }
    
    // Show modal
    this.modalTarget.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
  }

  openEdit(event) {
    event.preventDefault()
    
    const availabilityId = event.currentTarget.dataset.availabilityModalAvailabilityIdValue
    const dayOfWeek = event.currentTarget.dataset.availabilityModalDayOfWeekValue
    const dayName = event.currentTarget.dataset.availabilityModalDayNameValue
    const startTime = event.currentTarget.dataset.availabilityModalStartTimeValue
    const endTime = event.currentTarget.dataset.availabilityModalEndTimeValue
    
    // Set form values for edit
    this.dayOfWeekInputTarget.value = dayOfWeek
    this.dayNameTarget.textContent = dayName
    this.startTimeInputTarget.value = startTime
    this.endTimeInputTarget.value = endTime
    this.titleTarget.textContent = `Modifier un créneau - ${dayName}`
    
    // Update form action for update
    const baseUrl = window.location.origin + '/professional/availability_slots'
    this.formTarget.action = `${baseUrl}/${availabilityId}`
    
    // Add hidden method field for PATCH
    let methodInput = this.formTarget.querySelector('input[name="_method"]')
    if (!methodInput) {
      methodInput = document.createElement('input')
      methodInput.type = "hidden"
      methodInput.name = "_method"
      this.formTarget.appendChild(methodInput)
    }
    methodInput.value = "patch"
    
    // Show modal
    this.modalTarget.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
  }
}

