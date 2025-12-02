import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "preview", "toolbar"]

  connect() {
    // Load marked.js from CDN if not already loaded
    if (typeof marked === 'undefined') {
      const script = document.createElement('script')
      script.src = 'https://cdn.jsdelivr.net/npm/marked@11.1.1/marked.min.js'
      script.onload = () => {
        this.setupMarked()
        this.updatePreview()
      }
      document.head.appendChild(script)
    } else {
      this.setupMarked()
      this.updatePreview()
    }

    // Update preview on input
    this.textareaTarget.addEventListener('input', () => {
      this.updatePreview()
    })
  }

  setupMarked() {
    if (typeof marked !== 'undefined') {
      // Configure marked options
      marked.setOptions({
        breaks: true,
        gfm: true
      })
    }
  }

  updatePreview() {
    if (this.hasPreviewTarget && typeof marked !== 'undefined') {
      const markdown = this.textareaTarget.value || ''
      const html = marked.parse(markdown)
      this.previewTarget.innerHTML = html
    }
  }

  togglePreview(event) {
    event.preventDefault()
    const editorContainer = this.textareaTarget.closest('.markdown-editor-container')
    const previewContainer = this.element.querySelector('.markdown-preview-container')
    
    if (editorContainer && previewContainer) {
      const isHidden = previewContainer.classList.contains('hidden')
      
      if (isHidden) {
        // Show preview
        editorContainer.classList.add('hidden')
        previewContainer.classList.remove('hidden')
        this.updatePreview()
        event.target.textContent = 'Éditer'
      } else {
        // Show editor
        editorContainer.classList.remove('hidden')
        previewContainer.classList.add('hidden')
        event.target.textContent = 'Aperçu'
      }
    }
  }

  insertMarkdown(event) {
    event.preventDefault()
    const textarea = this.textareaTarget
    const type = event.currentTarget.dataset.actionValue
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const selectedText = textarea.value.substring(start, end)
    let insertText = ''
    let cursorOffset = 0

    switch (type) {
      case 'h1':
        insertText = `# ${selectedText || 'Titre principal'}`
        cursorOffset = selectedText ? 0 : -14
        break
      case 'h2':
        insertText = `## ${selectedText || 'Sous-titre'}`
        cursorOffset = selectedText ? 0 : -12
        break
      case 'h3':
        insertText = `### ${selectedText || 'Sous-titre niveau 3'}`
        cursorOffset = selectedText ? 0 : -18
        break
      case 'bold':
        insertText = `**${selectedText || 'texte en gras'}**`
        cursorOffset = selectedText ? 0 : -15
        break
      case 'italic':
        insertText = `*${selectedText || 'texte en italique'}*`
        cursorOffset = selectedText ? 0 : -18
        break
      case 'ul':
        insertText = selectedText 
          ? selectedText.split('\n').map(line => `- ${line}`).join('\n')
          : `- Élément de liste`
        cursorOffset = selectedText ? 0 : -16
        break
      case 'ol':
        insertText = selectedText
          ? selectedText.split('\n').map((line, index) => `${index + 1}. ${line}`).join('\n')
          : `1. Élément de liste`
        cursorOffset = selectedText ? 0 : -18
        break
      case 'link':
        insertText = `[${selectedText || 'texte du lien'}](https://exemple.com)`
        cursorOffset = selectedText ? -1 : -28
        break
    }

    // Insert the markdown
    textarea.value = textarea.value.substring(0, start) + insertText + textarea.value.substring(end)
    
    // Set cursor position
    const newPosition = start + insertText.length + cursorOffset
    textarea.setSelectionRange(newPosition, newPosition)
    textarea.focus()
    
    // Update preview
    this.updatePreview()
  }
}
