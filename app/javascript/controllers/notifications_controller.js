import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values = {
    hasMenu: { type: Boolean, default: false }
  }

  connect() {
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
    try {
      const notificationElement = event.currentTarget.closest("[id^='notification_']")
      if (!notificationElement) return
      
      const notificationId = notificationElement.id.split('_')[1]
      if (!notificationId) return
      
      fetch(`/notifications/${notificationId}/mark_as_read`, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        },
        credentials: 'same-origin'
      }).catch(error => console.error("Error marking notification as read:", error))
    } catch (error) {
      console.error("Error in markAsRead:", error)
    }
  }

  markAsReadAndNavigate(event) {
    event.preventDefault()
    try {
      const link = event.currentTarget
      const notificationId = link.dataset.notificationId
      if (!notificationId) return
      
      fetch(`/notifications/${notificationId}/mark_as_read`, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        },
        credentials: 'same-origin'
      })
      .then(() => Turbo.visit(link.href))
      .catch(error => {
        console.error("Error marking notification as read:", error)
        // Still navigate even if marking as read fails
        Turbo.visit(link.href)
      })
    } catch (error) {
      console.error("Error in markAsReadAndNavigate:", error)
      // Try to navigate even if there's an error
      const link = event.currentTarget
      if (link?.href) Turbo.visit(link.href)
    }
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  disconnect() {
    if (this.hasMenuValue) {
      document.removeEventListener("click", this.clickOutside.bind(this))
    }
  }
}
