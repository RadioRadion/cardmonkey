import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    this.debounceTimeout = null
    this.resultsTarget.style.display = 'none'
  }

  search() {
    // Clear any existing timeout
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }

    // Set a new timeout
    this.debounceTimeout = setTimeout(() => {
      const query = this.inputTarget.value.trim()
      
      // Hide results if query is too short
      if (query.length < 3) {
        this.resultsTarget.style.display = 'none'
        return
      }

      const url = `/users/search?query=${encodeURIComponent(query)}`
      fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })
      .then(response => response.text())
      .then(html => {
        if (html.trim()) {
          this.resultsTarget.style.display = 'block'
          Turbo.renderStreamMessage(html)
        }
      })
    }, 300) // 300ms delay
  }

  // Hide results when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.resultsTarget.style.display = 'none'
    }
  }

  // Method to handle when input loses focus
  blur() {
    // Small delay to allow for result clicks
    setTimeout(() => {
      if (!this.element.contains(document.activeElement)) {
        this.resultsTarget.style.display = 'none'
      }
    }, 200)
  }

  disconnect() {
    // Clean up timeout when controller is disconnected
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }
  }
}
