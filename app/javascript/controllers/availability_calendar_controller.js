import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["monthDisplay", "modal", "modalDate", "modalTitle", "modalContent", "manualBookingModal", "manualBookingContent"]
  static values = {
    currentMonth: Number,
    currentYear: Number,
    calendarPath: String
  }

  connect() {
    // Initialize from data attributes or use current date
    if (!this.currentMonthValue) {
      this.currentMonthValue = new Date().getMonth() + 1
    }
    if (!this.currentYearValue) {
      this.currentYearValue = new Date().getFullYear()
    }
  }

  previousMonth(event) {
    event.preventDefault()
    let newMonth = this.currentMonthValue - 1
    let newYear = this.currentYearValue
    
    if (newMonth < 1) {
      newMonth = 12
      newYear -= 1
    }
    
    this.navigateToMonth(newMonth, newYear)
  }

  nextMonth(event) {
    event.preventDefault()
    let newMonth = this.currentMonthValue + 1
    let newYear = this.currentYearValue
    
    if (newMonth > 12) {
      newMonth = 1
      newYear += 1
    }
    
    this.navigateToMonth(newMonth, newYear)
  }

  navigateToMonth(month, year) {
    const url = new URL(this.calendarPathValue || window.location.pathname, window.location.origin)
    url.searchParams.set('month', month)
    url.searchParams.set('year', year)
    window.location.href = url.toString()
  }

  openDayModal(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const date = event.currentTarget.dataset.date || event.target.closest('[data-date]')?.dataset.date
    if (!date) return
    
    // Load day details via AJAX
    this.loadDayDetails(date)
  }

  async loadDayDetails(date) {
    try {
      const url = new URL('/professional/availability_slots/day_details', window.location.origin)
      url.searchParams.set('date', date)
      
      const response = await fetch(url)
      if (!response.ok) {
        console.error('Error loading day details')
        return
      }
      
      const html = await response.text()
      this.modalContentTarget.innerHTML = html
      
      // Update modal title with date
      const dateObj = new Date(date)
      const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
      const formattedDate = dateObj.toLocaleDateString('fr-FR', options)
      this.modalTitleTarget.textContent = formattedDate
      
      // Show modal
      this.modalTarget.classList.remove('hidden')
      document.body.style.overflow = 'hidden'
    } catch (error) {
      console.error('Error loading day details:', error)
    }
  }

  closeModal(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    this.modalTarget.classList.add('hidden')
    document.body.style.overflow = ''
  }

  openManualBookingModal(event) {
    event.preventDefault()
    event.stopPropagation()
    
    this.loadManualBookingForm()
  }

  async loadManualBookingForm() {
    try {
      const url = new URL('/professional/manual_bookings/new', window.location.origin)
      
      const response = await fetch(url, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (!response.ok) {
        console.error('Error loading manual booking form')
        return
      }
      
      const html = await response.text()
      this.manualBookingContentTarget.innerHTML = html
      
      // Show modal
      this.manualBookingModalTarget.classList.remove('hidden')
      document.body.style.overflow = 'hidden'
    } catch (error) {
      console.error('Error loading manual booking form:', error)
    }
  }

  closeManualBookingModal(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    this.manualBookingModalTarget.classList.add('hidden')
    document.body.style.overflow = ''
  }
}

