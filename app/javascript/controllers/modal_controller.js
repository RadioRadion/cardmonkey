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