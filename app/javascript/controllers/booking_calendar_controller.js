import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booking-calendar"
export default class extends Controller {
  static targets = [
    "calendar",
    "selectedDate",
    "selectedTime",
    "selectedTimeContainer",
    "scheduledAtInput",
    "monthDisplay",
    "prevMonth",
    "nextMonth",
    "timeSlots",
    "serviceDuration",
    "serviceDurationText",
    "professionalServiceSelect"
  ]
  static values = {
    professionalId: Number,
    professionalServiceId: Number,
    excludeBookingId: Number,
    currentMonth: Number,
    currentYear: Number,
    selectedDate: String,
    selectedTime: String,
    services: Object
  }

  connect() {
    this.currentMonth = this.currentMonthValue || new Date().getMonth() + 1
    this.currentYear = this.currentYearValue || new Date().getFullYear()
    this.selectedDateValue = null
    this.selectedTimeValue = null
    
    // Update service duration if service is already selected
    this.updateServiceDuration()
    
    // Load slots if professional_service_id is already set
    if (this.professionalServiceIdValue && this.professionalIdValue) {
      this.loadAvailableSlots()
    }
  }

  async loadAvailableSlots() {
    if (!this.professionalIdValue || !this.professionalServiceIdValue) {
      console.log('Missing values:', { professionalId: this.professionalIdValue, professionalServiceId: this.professionalServiceIdValue })
      return
    }

    const url = new URL('/client/bookings/available_slots', window.location.origin)
    url.searchParams.set('professional_id', this.professionalIdValue)
    url.searchParams.set('professional_service_id', this.professionalServiceIdValue)
    url.searchParams.set('month', this.currentMonth)
    url.searchParams.set('year', this.currentYear)
    if (this.excludeBookingIdValue) {
      url.searchParams.set('exclude_booking_id', this.excludeBookingIdValue)
    }

    try {
      const response = await fetch(url)
      if (!response.ok) {
        console.error('Error response:', response.status, await response.text())
        return
      }
      const data = await response.json()
      console.log('Loaded slots:', Object.keys(data.slots || {}).length, 'days')
      this.renderCalendar(data.slots || {})
    } catch (error) {
      console.error('Error loading available slots:', error)
    }
  }

  renderCalendar(slots) {
    const firstDay = new Date(this.currentYear, this.currentMonth - 1, 1)
    const lastDay = new Date(this.currentYear, this.currentMonth, 0)
    const daysInMonth = lastDay.getDate()
    const startingDayOfWeek = firstDay.getDay() === 0 ? 6 : firstDay.getDay() - 1 // Monday = 0

    // Update month display
    const monthNames = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 
                       'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
    this.monthDisplayTarget.textContent = `${monthNames[this.currentMonth - 1]} ${this.currentYear}`

    // Clear calendar
    this.calendarTarget.innerHTML = ''

    // Add day headers
    const dayHeaders = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
    const headerRow = document.createElement('div')
    headerRow.className = 'grid grid-cols-7 gap-2 mb-2'
    dayHeaders.forEach(day => {
      const header = document.createElement('div')
      header.className = 'text-center text-sm font-bold text-gray-700 py-2'
      header.textContent = day
      headerRow.appendChild(header)
    })
    this.calendarTarget.appendChild(headerRow)

    // Add empty cells for days before month starts
    const calendarGrid = document.createElement('div')
    calendarGrid.className = 'grid grid-cols-7 gap-2'
    
    for (let i = 0; i < startingDayOfWeek; i++) {
      const emptyCell = document.createElement('div')
      emptyCell.className = 'h-16'
      calendarGrid.appendChild(emptyCell)
    }

    // Add days of month
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(this.currentYear, this.currentMonth - 1, day)
      // Format date as YYYY-MM-DD in local timezone (not UTC)
      const year = date.getFullYear()
      const month = String(date.getMonth() + 1).padStart(2, '0')
      const dayStr = String(date.getDate()).padStart(2, '0')
      const dateString = `${year}-${month}-${dayStr}`
      const daySlots = slots[dateString] || []
      const hasSlots = daySlots.length > 0
      const isPast = date < today
      const isSelected = this.selectedDateValue === dateString

      const dayCell = document.createElement('div')
      dayCell.className = `h-16 border-2 rounded-lg p-2 cursor-pointer transition-colors ${
        isSelected 
          ? 'border-red-hero bg-red-50' 
          : hasSlots && !isPast
            ? 'border-gray-200 hover:border-red-hero hover:bg-red-50'
            : 'border-gray-100 bg-gray-50 opacity-50 cursor-not-allowed'
      }`
      
      if (hasSlots && !isPast) {
        dayCell.addEventListener('click', () => this.selectDate(dateString, daySlots))
      }

      const dayNumber = document.createElement('div')
      dayNumber.className = `text-sm font-bold ${isSelected ? 'text-red-hero' : 'text-gray-900'}`
      dayNumber.textContent = day
      dayCell.appendChild(dayNumber)

      if (hasSlots) {
        const slotCount = document.createElement('div')
        slotCount.className = 'text-xs text-gray-600 mt-1'
        slotCount.textContent = `${daySlots.length} créneau${daySlots.length > 1 ? 'x' : ''}`
        dayCell.appendChild(slotCount)
      }

      calendarGrid.appendChild(dayCell)
    }

    this.calendarTarget.appendChild(calendarGrid)
  }

  selectDate(dateString, slots) {
    this.selectedDateValue = dateString
    this.selectedTimeValue = null
    
    // Update selected date display
    // Parse dateString (YYYY-MM-DD) in local timezone
    const [year, month, day] = dateString.split('-').map(Number)
    const date = new Date(year, month - 1, day)
    const dayNames = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi']
    const monthNames = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 
                       'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre']
    const formattedDate = `${dayNames[date.getDay()]} ${date.getDate()} ${monthNames[date.getMonth()]}`
    if (this.hasSelectedDateTarget) {
      this.selectedDateTarget.textContent = formattedDate
    }

    // Render time slots
    this.renderTimeSlots(slots)
    
    // Clear scheduled_at input
    if (this.hasScheduledAtInputTarget) {
      this.scheduledAtInputTarget.value = ''
    }
  }

  renderTimeSlots(slots) {
    if (!this.hasTimeSlotsTarget) return

    this.timeSlotsTarget.innerHTML = ''
    this.timeSlotsTarget.classList.remove('hidden')

    if (slots.length === 0) {
      this.timeSlotsTarget.innerHTML = '<p class="text-gray-500 text-sm">Aucun créneau disponible pour ce jour</p>'
      return
    }

    const slotsContainer = document.createElement('div')
    slotsContainer.className = 'grid grid-cols-2 md:grid-cols-3 gap-2'

    slots.forEach(slot => {
      const slotButton = document.createElement('button')
      slotButton.type = 'button'
      slotButton.className = `px-4 py-2 border-2 rounded-lg text-sm font-medium transition-colors ${
        this.selectedTimeValue === slot.start
          ? 'border-red-hero bg-red-hero text-white'
          : 'border-gray-200 hover:border-red-hero hover:bg-red-50 text-gray-700'
      }`
      slotButton.textContent = slot.formatted
      slotButton.addEventListener('click', () => this.selectTime(slot.start))
      slotsContainer.appendChild(slotButton)
    })

    this.timeSlotsTarget.appendChild(slotsContainer)
  }

  selectTime(timeString) {
    this.selectedTimeValue = timeString
    
    // Update scheduled_at input
    if (this.hasScheduledAtInputTarget && this.selectedDateValue) {
      const dateTime = new Date(timeString)
      const localDateTime = new Date(dateTime.getTime() - dateTime.getTimezoneOffset() * 60000)
      this.scheduledAtInputTarget.value = localDateTime.toISOString().slice(0, 16)
    }

    // Update selected time display with duration
    if (this.hasSelectedTimeContainerTarget) {
      this.selectedTimeContainerTarget.style.display = 'block'
    }
    if (this.hasSelectedTimeTarget) {
      const time = new Date(timeString)
      const timeText = time.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
      
      // Get service duration
      let durationText = ''
      if (this.professionalServiceIdValue && this.servicesValue && this.servicesValue[this.professionalServiceIdValue]) {
        const service = this.servicesValue[this.professionalServiceIdValue]
        if (service && service.duration_minutes) {
          const hours = Math.floor(service.duration_minutes / 60)
          const minutes = service.duration_minutes % 60
          if (hours > 0 && minutes > 0) {
            durationText = ` (durée estimée: ${hours}h${minutes})`
          } else if (hours > 0) {
            durationText = ` (durée estimée: ${hours}h)`
          } else {
            durationText = ` (durée estimée: ${minutes} min)`
          }
        }
      }
      
      this.selectedTimeTarget.textContent = `${timeText}${durationText}`
    }
  }

  previousMonth(event) {
    event.preventDefault()
    if (this.currentMonth === 1) {
      this.currentMonth = 12
      this.currentYear--
    } else {
      this.currentMonth--
    }
    this.loadAvailableSlots()
  }

  nextMonth(event) {
    event.preventDefault()
    if (this.currentMonth === 12) {
      this.currentMonth = 1
      this.currentYear++
    } else {
      this.currentMonth++
    }
    this.loadAvailableSlots()
  }

  professionalServiceChanged(event) {
    if (event) {
      this.professionalServiceIdValue = event.target.value
    }
    
    // Update service duration display
    this.updateServiceDuration()
    
    this.selectedDateValue = null
    this.selectedTimeValue = null
    if (this.hasScheduledAtInputTarget) {
      this.scheduledAtInputTarget.value = ''
    }
    if (this.hasTimeSlotsTarget) {
      this.timeSlotsTarget.classList.add('hidden')
      this.timeSlotsTarget.innerHTML = ''
    }
    if (this.hasSelectedDateTarget) {
      this.selectedDateTarget.textContent = 'Aucune date sélectionnée'
    }
    if (this.hasSelectedTimeContainerTarget) {
      this.selectedTimeContainerTarget.style.display = 'none'
    }
    if (this.professionalServiceIdValue) {
      this.loadAvailableSlots()
    }
  }

  updateServiceDuration() {
    if (!this.professionalServiceIdValue || !this.hasServiceDurationTarget) {
      if (this.hasServiceDurationTarget) {
        this.serviceDurationTarget.classList.add('hidden')
      }
      return
    }

    if (!this.servicesValue || !this.servicesValue[this.professionalServiceIdValue]) {
      if (this.hasServiceDurationTarget) {
        this.serviceDurationTarget.classList.add('hidden')
      }
      return
    }

    const service = this.servicesValue[this.professionalServiceIdValue]
    if (service && service.duration_minutes) {
      const hours = Math.floor(service.duration_minutes / 60)
      const minutes = service.duration_minutes % 60
      let durationText = ''
      if (hours > 0 && minutes > 0) {
        durationText = `${hours}h${minutes}`
      } else if (hours > 0) {
        durationText = `${hours}h`
      } else {
        durationText = `${minutes} min`
      }

      if (this.hasServiceDurationTextTarget) {
        this.serviceDurationTextTarget.textContent = durationText
      }
      this.serviceDurationTarget.classList.remove('hidden')
    } else {
      this.serviceDurationTarget.classList.add('hidden')
    }
  }
}

