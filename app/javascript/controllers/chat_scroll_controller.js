import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { chatId: Number }

  connect() {
    // Scroll vers le bas au chargement de la page
    setTimeout(() => {
      this.scrollToBottom()
    }, 100)
    
    // Écouter les événements Turbo Stream pour le scroll automatique
    document.addEventListener("turbo:before-stream-render", this.handleBeforeStreamRender.bind(this))
    
    // Observer les changements dans le conteneur de messages
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
    })
    
    const messagesContainer = this.element.querySelector("#messages")
    if (messagesContainer) {
      this.observer.observe(messagesContainer, { childList: true, subtree: true })
    }
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.handleBeforeStreamRender.bind(this))
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleBeforeStreamRender(event) {
    // Si c'est une action de scroll pour ce chat, on scroll vers le bas
    const action = event.detail.render
    if (action.method === "action" && action.action === "scroll_to_bottom") {
      const targetId = action.target
      if (targetId === "messages_container") {
        // Attendre que le DOM soit mis à jour avant de scroller
        setTimeout(() => {
          this.scrollToBottom()
        }, 100)
      }
    }
  }

  scrollToBottom() {
    // Scroll vers le bas du conteneur avec animation smooth
    this.element.scrollTo({
      top: this.element.scrollHeight,
      behavior: "smooth"
    })
  }

  // Méthode appelée par Turbo Stream action
  scrollToBottomAction() {
    this.scrollToBottom()
  }
}

