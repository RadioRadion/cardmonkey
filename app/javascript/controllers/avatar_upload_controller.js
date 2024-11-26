import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "preview"]

  triggerInput(event) {
    this.inputTarget.click()
  }

  upload(event) {
    const input = event.target
    const files = input.files

    if (files && files.length > 0) {
      const file = files[0]
      const url = input.dataset.directUploadUrl
      const upload = new DirectUpload(file, url, this)

      upload.create((error, blob) => {
        if (error) {
          console.error('Error uploading file:', error)
        } else {
          // Create a hidden input to store the signed blob ID
          const hiddenField = document.createElement('input')
          hiddenField.setAttribute("type", "hidden")
          hiddenField.setAttribute("value", blob.signed_id)
          hiddenField.name = input.name
          
          // Replace the file input with the hidden field containing the blob ID
          input.parentNode.insertBefore(hiddenField, input)
          input.parentNode.removeChild(input)

          // Submit the form
          const form = this.element.closest('form')
          if (form) {
            form.dispatchEvent(new Event('submit', { cancelable: true }))
            if (!event.defaultPrevented) {
              form.submit()
            }
          }
        }
      })
    }
  }

  // DirectUpload delegate methods
  directUploadWillStoreFileWithXHR(xhr) {
    xhr.upload.addEventListener("progress", event => {
      const progress = event.loaded / event.total * 100
      // You can add progress indication here if needed
      console.log(`Upload progress: ${progress}%`)
    })
  }
}
