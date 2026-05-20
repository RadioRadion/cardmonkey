import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    confirmMessage: String
  }

  delete(event) {
    event.preventDefault()
    
    if (this.hasConfirmMessageValue && !confirm(this.confirmMessageValue)) {
      return
    }

    const form = event.target.closest('form')
    
    // Submit form with Turbo
    fetch(form.action, {
      method: 'DELETE',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    }).then(response => {
      if (response.ok) {
        // Handle successful deletion
        const cardElement = form.closest('[data-card-id]')
        if (cardElement) {
          cardElement.remove()
        }
      }
    })
  }
}
