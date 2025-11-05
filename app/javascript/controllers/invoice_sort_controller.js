import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["table", "row"]
  static values = {
    column: String,
    direction: String
  }

  connect() {
    this.columnValue = ""
    this.directionValue = "asc"
  }

  sort(event) {
    const column = event.currentTarget.dataset.column
    const tbody = this.tableTarget.querySelector("tbody")
    const rows = Array.from(this.rowTargets)

    // Toggle direction if clicking the same column
    if (this.columnValue === column) {
      this.directionValue = this.directionValue === "asc" ? "desc" : "asc"
    } else {
      this.columnValue = column
      this.directionValue = "asc"
    }

    // Sort rows
    rows.sort((a, b) => {
      const aValue = this.getCellValue(a, column)
      const bValue = this.getCellValue(b, column)

      let comparison = 0
      
      if (column === "amount") {
        // Sort by numeric value for amounts
        const aNum = parseFloat(aValue.replace(/[€\s]/g, ''))
        const bNum = parseFloat(bValue.replace(/[€\s]/g, ''))
        comparison = aNum - bNum
      } else if (column === "date") {
        // Sort by date
        const aDate = this.parseDate(aValue)
        const bDate = this.parseDate(bValue)
        comparison = aDate - bDate
      } else if (column === "number") {
        // Sort by invoice number
        const aNum = parseInt(aValue.replace(/[^\d]/g, ''))
        const bNum = parseInt(bValue.replace(/[^\d]/g, ''))
        comparison = aNum - bNum
      } else {
        // Sort alphabetically for service/client
        comparison = aValue.localeCompare(bValue, 'fr')
      }

      return this.directionValue === "asc" ? comparison : -comparison
    })

    // Reorder rows in DOM
    rows.forEach(row => tbody.appendChild(row))

    // Update sort indicators
    this.updateSortIndicators(column)
  }

  getCellValue(row, column) {
    const columnIndex = {
      'number': 0,
      'client': 1,
      'service': 2,
      'date': 3,
      'amount': 4
    }

    const cell = row.cells[columnIndex[column]]
    return cell ? cell.textContent.trim() : ''
  }

  parseDate(dateStr) {
    // Parse date in DD/MM/YYYY format
    const parts = dateStr.split('/')
    if (parts.length === 3) {
      return new Date(parts[2], parts[1] - 1, parts[0])
    }
    return new Date(0)
  }

  updateSortIndicators(activeColumn) {
    // Update all header indicators
    const headers = this.element.querySelectorAll('[data-column]')
    headers.forEach(header => {
      const column = header.dataset.column
      const indicator = header.querySelector('.sort-indicator')
      
      if (column === activeColumn) {
        indicator.classList.remove('opacity-30')
        indicator.classList.add('opacity-100')
        
        if (this.directionValue === "asc") {
          indicator.innerHTML = '↑'
        } else {
          indicator.innerHTML = '↓'
        }
      } else {
        indicator.classList.remove('opacity-100')
        indicator.classList.add('opacity-30')
        indicator.innerHTML = '↕'
      }
    })
  }
}
