import { Controller } from "@hotwired/stimulus"

// Controller for server-side filtering with Turbo
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.timeout = null
  }

  submit() {
    this.element.requestSubmit()
  }

  debounceSubmit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.submit()
    }, 300) // 300ms debounce for search input
  }
}
