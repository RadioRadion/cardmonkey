import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Add event listener to close dropdown when clicking outside
    this.handleClickOutsideBound = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutsideBound)
    
    // Use turbo:before-cache instead of turbo:click
    this.hideBound = this.hide.bind(this)
    document.addEventListener("turbo:before-cache", this.hideBound)
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener("click", this.handleClickOutsideBound)
    document.removeEventListener("turbo:before-cache", this.hideBound)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  hide() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden")
    }
  }

  handleClickOutside(event) {
    if (this.element && !this.element.contains(event.target)) {
      this.hide()
    }
  }
}
