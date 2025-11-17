import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin-notes"
// Handles AJAX saving of admin approval notes
export default class extends Controller {
  static targets = ["textarea", "saveButton", "statusMessage"]
  static values = { userId: String }

  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
  }

  async save() {
    const textarea = this.textareaTarget
    const saveButton = this.saveButtonTarget
    const statusMessage = this.statusMessageTarget
    const userId = this.userIdValue
    const notes = textarea.value

    // Disable button and show loading state
    saveButton.disabled = true
    saveButton.classList.add("opacity-50", "cursor-not-allowed")
    const originalText = saveButton.innerHTML
    saveButton.innerHTML = '<svg class="w-4 h-4 mr-2 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>Enregistrement...'

    try {
      const response = await fetch(`/admin/professional_approvals/${userId}/update_notes`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ admin_approval_note: notes })
      })

      const data = await response.json()

      if (response.ok && data.status === "success") {
        // Show success message
        statusMessage.textContent = "Notes enregistrées avec succès."
        statusMessage.classList.remove("hidden", "text-red-600")
        statusMessage.classList.add("text-green-600")
        
        // Hide message after 3 seconds
        setTimeout(() => {
          statusMessage.classList.add("hidden")
        }, 3000)
      } else {
        throw new Error(data.errors?.join(", ") || "Erreur lors de l'enregistrement")
      }
    } catch (error) {
      // Show error message
      statusMessage.textContent = error.message || "Erreur lors de l'enregistrement des notes."
      statusMessage.classList.remove("hidden", "text-green-600")
      statusMessage.classList.add("text-red-600")
      
      // Hide message after 5 seconds
      setTimeout(() => {
        statusMessage.classList.add("hidden")
      }, 5000)
    } finally {
      // Re-enable button
      saveButton.disabled = false
      saveButton.classList.remove("opacity-50", "cursor-not-allowed")
      saveButton.innerHTML = originalText
    }
  }
}

