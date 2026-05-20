import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

// Ensure DirectUpload is available
if (!window.DirectUpload) {
  console.error("DirectUpload not found. Make sure @rails/activestorage is properly imported.")
}

export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    if (!window.DirectUpload) {
      console.error("DirectUpload not available")
      return
    }
  }

  triggerInput(event) {
    this.inputTarget.click()
  }

  async upload(event) {
    const input = event.target
    const files = input.files

    if (files && files.length > 0) {
      const file = files[0]
      
      // Validate file type
      if (!file.type.startsWith('image/')) {
        console.error('Invalid file type')
        alert('Veuillez sélectionner une image valide')
        return
      }

      // Create a sanitized filename
      const extension = file.name.split('.').pop()
      const timestamp = new Date().getTime()
      const sanitizedFilename = `avatar_${timestamp}.${extension}`
      
      // Create a new file with sanitized name
      const sanitizedFile = new File([file], sanitizedFilename, {
        type: file.type,
        lastModified: file.lastModified
      })

      const url = input.dataset.directUploadUrl
      const upload = new DirectUpload(sanitizedFile, url, this)

      try {
        // Show loading state
        this.element.classList.add('uploading')
        if (this.hasPreviewTarget) {
          this.previewTarget.style.opacity = '0.5'
        }

        // Wrap the upload.create in a Promise
        const blob = await new Promise((resolve, reject) => {
          upload.create((error, blob) => {
            if (error) {
              reject(error)
            } else {
              resolve(blob)
            }
          })
        })

        // Create hidden field with blob id
        const hiddenField = document.createElement('input')
        hiddenField.setAttribute("type", "hidden")
        hiddenField.setAttribute("value", blob.signed_id)
        hiddenField.name = input.name

        // Replace the file input with the hidden field
        const form = input.closest('form')
        form.appendChild(hiddenField)

        // Submit the form
        if (form) {
          form.requestSubmit()
        }

      } catch (error) {
        console.error('Upload error:', error)
        alert('Une erreur est survenue lors du téléchargement. Veuillez réessayer.')
      } finally {
        // Reset loading state
        this.element.classList.remove('uploading')
        if (this.hasPreviewTarget) {
          this.previewTarget.style.opacity = '1'
        }
      }
    }
  }

  directUploadWillStoreFileWithXHR(xhr) {
    // Add CSRF token to request headers
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (token) {
      xhr.setRequestHeader('X-CSRF-Token', token)
    }

    // Add progress handler
    xhr.upload.addEventListener("progress", event => {
      const progress = event.loaded / event.total * 100
      console.log(`Upload progress: ${progress}%`)
    })

    // Add error handler
    xhr.addEventListener("error", event => {
      console.error('XHR error:', event)
    })
  }
}
