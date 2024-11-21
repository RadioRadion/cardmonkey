// app/javascript/controllers/avatar_upload_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button", "preview"]
  static classes = ["loading"]

  connect() {
    this.isUploading = false
  }

  triggerInput() {
    if (!this.isUploading) {
      this.inputTarget.click()
    }
  }

  async upload(event) {
    if (this.isUploading) return

    const file = event.target.files[0]
    if (!file) return

    // Validate file type
    if (!file.type.match(/^image\/(jpg|jpeg|png|gif)$/)) {
      this.showError("Please select an image file (JPG, PNG, or GIF)")
      return
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      this.showError("File size must be less than 5MB")
      return
    }

    try {
      this.isUploading = true
      this.showLoading()

      // If you have a preview target, show image preview
      if (this.hasPreviewTarget) {
        const reader = new FileReader()
        reader.onload = (e) => {
          this.previewTarget.src = e.target.result
        }
        reader.readAsDataURL(file)
      }

      // Submit the form
      await this.element.requestSubmit()
    } catch (error) {
      this.showError("Failed to upload image. Please try again.")
    } finally {
      this.isUploading = false
      this.hideLoading()
    }
  }

  showLoading() {
    if (this.hasButtonTarget) {
      this.buttonTarget.innerHTML = `
        <svg class="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
      `
    }
  }

  hideLoading() {
    if (this.hasButtonTarget) {
      this.buttonTarget.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
      `
    }
  }

  showError(message) {
    // Create and show error notification
    const notification = document.createElement('div')
    notification.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg transform transition-all duration-500 ease-in-out z-50'
    notification.textContent = message
    document.body.appendChild(notification)

    // Remove notification after 3 seconds
    setTimeout(() => {
      notification.style.opacity = '0'
      setTimeout(() => notification.remove(), 500)
    }, 3000)
  }
}
