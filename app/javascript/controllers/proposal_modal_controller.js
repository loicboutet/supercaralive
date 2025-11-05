import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "priceInput", "datetimeInput", "bookingIdInput"]
  static values = {
    bookingId: String,
    currentPrice: String,
    currentDatetime: String
  }

  open(event) {
    event.preventDefault()
    
    // Get booking data from the button's data attributes
    const button = event.currentTarget
    const bookingId = button.dataset.proposalModalBookingIdParam
    const currentPrice = button.dataset.proposalModalCurrentPriceParam
    const currentDatetime = button.dataset.proposalModalCurrentDatetimeParam
    
    // Populate form fields with current booking data
    const priceInput = this.modalTarget.querySelector('input[type="number"]')
    const datetimeInput = this.modalTarget.querySelector('input[type="datetime-local"]')
    
    if (priceInput && currentPrice) {
      priceInput.value = currentPrice
    }
    
    if (datetimeInput && currentDatetime) {
      datetimeInput.value = currentDatetime
    }
    
    // Store booking ID for form submission (would be used when backend is implemented)
    this.currentBookingId = bookingId
    
    // Show the modal
    this.modalTarget.classList.remove("hidden")
  }

  close(event) {
    event.preventDefault()
    this.modalTarget.classList.add("hidden")
    
    // Clear form fields when closing
    const priceInput = this.modalTarget.querySelector('input[type="number"]')
    const datetimeInput = this.modalTarget.querySelector('input[type="datetime-local"]')
    const messageInput = this.modalTarget.querySelector('textarea')
    
    if (priceInput) priceInput.value = ''
    if (datetimeInput) datetimeInput.value = ''
    if (messageInput) messageInput.value = ''
  }

  // Close modal when clicking outside
  closeOnOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.close(event)
    }
  }

  connect() {
    // Add click handler on the modal backdrop
    this.modalTarget.addEventListener("click", this.closeOnOutsideClick.bind(this))
  }

  disconnect() {
    this.modalTarget.removeEventListener("click", this.closeOnOutsideClick.bind(this))
  }
}
