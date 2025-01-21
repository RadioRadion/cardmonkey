import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values = {
    hasMenu: { type: Boolean, default: false }
  }

  connect() {
    // Add click outside listener if we have a menu
    if (this.hasMenuValue) {
      document.addEventListener("click", this.clickOutside.bind(this))
    }
  }

  toggle() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("hidden")
    }
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

  markAsReadAndNavigate(event) {
    event.preventDefault()
    const link = event.currentTarget
    const notificationId = link.dataset.notificationId
    
    // Send request to mark as read
    fetch(`/notifications/${notificationId}/mark_as_read`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      credentials: 'same-origin'
    }).then(() => {
      // Navigate to the trade page after marking as read
      window.location.href = link.href
    })
  }

  // Close dropdown when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  disconnect() {
    // Remove click outside listener if we had one
    if (this.hasMenuValue) {
      document.removeEventListener("click", this.clickOutside.bind(this))
    }
  }
}
