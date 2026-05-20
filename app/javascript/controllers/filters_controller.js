// app/javascript/controllers/filters_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "toggleText", "toggleIcon"]

  connect() {
    this.updateToggleIcon()
  }

  toggle() {
    this.contentTarget.classList.toggle('hidden')
    this.updateToggleIcon()
  }

  updateToggleIcon() {
    const isHidden = this.contentTarget.classList.contains('hidden')
    this.toggleTextTarget.textContent = isHidden ? 'Afficher' : 'Masquer'
    this.toggleIconTarget.innerHTML = isHidden 
      ? '<path d="M19 9l-7 7-7-7" />'
      : '<path d="M5 15l7-7 7 7" />'
  }

  applyFilter() {
    // On ajoute un petit délai pour ne pas surcharger le serveur
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.timeout = setTimeout(() => {
      const form = this.element.closest('form')
      if (!form) return

      const formData = new FormData(form)
      const params = new URLSearchParams(formData)
      
      fetch(`${form.action}?${params}`, {
        headers: { "Accept": "text/vnd.turbo-stream.html" }
      })
    }, 300)
  }
}