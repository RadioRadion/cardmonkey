import { Controller } from "@hotwired/stimulus"

// Définir explicitement le nom du controller
export default class extends Controller {
  static targets = ["form"]

  connect() {
    // S'assurer que l'élément est un formulaire
    if (!(this.element instanceof HTMLFormElement)) {
      console.error("Le controller reset-form doit être attaché à un élément form")
      return
    }
    this.element.addEventListener("turbo:submit-end", this.handleSubmit.bind(this))
  }

  disconnect() {
    if (this.element instanceof HTMLFormElement) {
      this.element.removeEventListener("turbo:submit-end", this.handleSubmit.bind(this))
    }
  }

  handleSubmit(event) {
    if (event.detail.success) {
      // S'assurer que l'élément est un formulaire avant d'appeler reset()
      if (this.element instanceof HTMLFormElement) {
        this.element.reset()
        this.focusInput()
      }
    }
  }

  focusInput() {
    const input = this.element.querySelector("input[type='text']")
    if (input) {
      input.focus()
    }
  }
}
