import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("turbo:submit-end", this.handleSubmit.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmit.bind(this))
  }

  handleSubmit(event) {
    if (event.detail.success) {
      this.element.reset()
      this.focusInput()
    }
  }

  focusInput() {
    const input = this.element.querySelector("input[type='text']")
    if (input) {
      input.focus()
    }
  }
}
