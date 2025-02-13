import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "editForm", "input"]

  connect() {
    this.messageId = this.element.dataset.messageId
    this.isEditable = this.element.dataset.messageEditable === "true"
  }

  edit() {
    if (!this.isEditable) return
    
    this.contentTarget.classList.add("hidden")
    this.editFormTarget.classList.remove("hidden")
    this.inputTarget.value = this.contentTarget.textContent.trim()
    this.inputTarget.focus()
  }

  cancelEdit() {
    this.contentTarget.classList.remove("hidden")
    this.editFormTarget.classList.add("hidden")
  }

  async update(event) {
    event.preventDefault()
    if (!this.isEditable) return

    try {
      const response = await fetch(`/messages/${this.messageId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        },
        body: JSON.stringify({
          message: {
            content: this.inputTarget.value.trim()
          }
        })
      })

      if (!response.ok) throw new Error('Failed to update message')
      
      // The server will broadcast the update through ActionCable
      this.cancelEdit()
    } catch (error) {
      console.error('Error updating message:', error)
      // Show error notification
    }
  }

  async delete(event) {
    if (!this.isEditable) return
    if (!confirm(event.target.dataset.confirm)) return

    try {
      const response = await fetch(`/messages/${this.messageId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        }
      })

      if (!response.ok) throw new Error('Failed to delete message')
      
      // The server will broadcast the deletion through ActionCable
      this.element.remove()
    } catch (error) {
      console.error('Error deleting message:', error)
      // Show error notification
    }
  }
}
