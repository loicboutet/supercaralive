import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="photo-upload"
export default class extends Controller {
  static targets = ["input", "preview", "fileName", "removeCheckbox"]
  static values = {
    maxWidth: { type: Number, default: 800 },
    maxHeight: { type: Number, default: 800 },
    quality: { type: Number, default: 0.8 }
  }

  connect() {
    // Initialize preview if file already exists
    this.updatePreview()
  }

  selectFile() {
    this.inputTarget.click()
  }

  async fileSelected(event) {
    const file = event.target.files[0]
    if (file) {
      try {
        // Compress the image before displaying and uploading
        const compressedFile = await this.compressImage(file)
        
        // Replace the file in the input with the compressed version
        const dataTransfer = new DataTransfer()
        dataTransfer.items.add(compressedFile)
        this.inputTarget.files = dataTransfer.files
        
        this.displayFileName(compressedFile.name)
        this.showPreview(compressedFile)
        
        // Uncheck remove checkbox if user selects a new file
        if (this.hasRemoveCheckboxTarget) {
          this.removeCheckboxTarget.checked = false
        }
      } catch (error) {
        console.error("Error compressing image:", error)
        // Fallback to original file if compression fails
        this.displayFileName(file.name)
        this.showPreview(file)
        if (this.hasRemoveCheckboxTarget) {
          this.removeCheckboxTarget.checked = false
        }
      }
    }
  }

  compressImage(file) {
    return new Promise((resolve, reject) => {
      // Check if file is an image
      if (!file.type.match(/^image\/(jpeg|jpg|png)$/)) {
        resolve(file) // Return original file if not an image
        return
      }

      const reader = new FileReader()
      reader.onload = (e) => {
        const img = new Image()
        img.onload = () => {
          // Calculate new dimensions
          let width = img.width
          let height = img.height

          if (width > this.maxWidthValue || height > this.maxHeightValue) {
            const ratio = Math.min(this.maxWidthValue / width, this.maxHeightValue / height)
            width = width * ratio
            height = height * ratio
          }

          // Create canvas and draw resized image
          const canvas = document.createElement('canvas')
          canvas.width = width
          canvas.height = height
          const ctx = canvas.getContext('2d')
          ctx.drawImage(img, 0, 0, width, height)

          // Convert to blob with compression
          canvas.toBlob(
            (blob) => {
              if (blob) {
                // Create a new File object with the compressed blob
                const compressedFile = new File([blob], file.name, {
                  type: 'image/jpeg',
                  lastModified: Date.now()
                })
                resolve(compressedFile)
              } else {
                reject(new Error("Failed to compress image"))
              }
            },
            'image/jpeg',
            this.qualityValue
          )
        }
        img.onerror = () => reject(new Error("Failed to load image"))
        img.src = e.target.result
      }
      reader.onerror = () => reject(new Error("Failed to read file"))
      reader.readAsDataURL(file)
    })
  }

  displayFileName(fileName) {
    if (this.hasFileNameTarget) {
      this.fileNameTarget.textContent = fileName
      this.fileNameTarget.classList.remove("hidden")
    }
  }

  showPreview(file) {
    if (this.hasPreviewTarget && file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("hidden")
        // Hide initials if preview is shown
        const initialsElement = this.element.querySelector('[data-photo-upload-target="initials"]')
        if (initialsElement) {
          initialsElement.classList.add("hidden")
        }
      }
      reader.readAsDataURL(file)
    }
  }

  updatePreview() {
    // If there's already a preview image (from existing photo), show it
    // Only hide initials if the image has a valid src (not empty and not a data URL from file selection)
    if (this.hasPreviewTarget && this.previewTarget.src && this.previewTarget.src.trim() !== "" && !this.previewTarget.src.includes("data:")) {
      this.previewTarget.classList.remove("hidden")
      const initialsElement = this.element.querySelector('[data-photo-upload-target="initials"]')
      if (initialsElement) {
        initialsElement.classList.add("hidden")
      }
    }
  }

  removePhoto() {
    if (this.hasRemoveCheckboxTarget) {
      this.removeCheckboxTarget.checked = true
      // Hide preview and show initials
      if (this.hasPreviewTarget) {
        this.previewTarget.classList.add("hidden")
        const initialsElement = this.element.querySelector('[data-photo-upload-target="initials"]')
        if (initialsElement) {
          initialsElement.classList.remove("hidden")
        }
      }
      // Clear file input
      if (this.hasInputTarget) {
        this.inputTarget.value = ""
      }
      // Hide file name
      if (this.hasFileNameTarget) {
        this.fileNameTarget.classList.add("hidden")
      }
    }
  }
}

