import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  markAsRead(event) {
    // Don't prevent the default link behavior
    const notificationId = event.currentTarget.closest("[id^='notification_']").id.split('_')[1]
    
    // Send request to mark as read
    fetch(`/notifications/${notificationId}/mark_as_read`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      credentials: 'same-origin'
    })
  }

  // Close dropdown when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  connect() {
    // Add click outside listener
    document.addEventListener("click", this.clickOutside.bind(this))
  }

  disconnect() {
    // Remove click outside listener
    document.removeEventListener("click", this.clickOutside.bind(this))
  }
}
