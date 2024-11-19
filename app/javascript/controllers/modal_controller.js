// app/javascript/controllers/trade_controller.js
export default class extends Controller {
  initiate(event) {
    const userId = event.currentTarget.dataset.tradeUserId
    const modal = document.getElementById('trade-modal')
    modal.classList.remove('hidden')
    
    // Stocker l'ID de l'utilisateur pour le trade
    this.userId = userId
  }

  create() {
    // Créer le trade via l'API
    fetch('/trades', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({
        user_id_invit: this.userId
      })
    }).then(response => {
      if (response.ok) {
        window.location.href = response.headers.get("Location")
      }
    })
  }
}

// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  closeOnClickOutside(event) {
    if (event.target === this.element) {
      this.close()
    }
  }

  close() {
    this.element.classList.add('hidden')
  }
}