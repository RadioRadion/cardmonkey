import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  triggerInput(event) {
    this.inputTarget.click()
  }

  upload(event) {
    const form = this.element.closest('form')
    if (form) {
      // Use submit() instead of requestSubmit() for better compatibility
      form.dispatchEvent(new Event('submit', { cancelable: true }))
      if (!event.defaultPrevented) {
        form.submit()
      }
    }
  }
}
