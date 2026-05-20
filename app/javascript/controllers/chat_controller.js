import { Controller } from "@hotwired/stimulus"
import { createChatroomSubscription, unsubscribeFromChatroom } from "../channels/chatroom_channel"

export default class extends Controller {
  static targets = ["messages", "messageList", "form"]

  connect() {
    this.setupSubscription()
    this.scrollToBottom()
  }

  disconnect() {
    const chatroomId = this.messagesTarget?.dataset.chatroomId
    if (chatroomId) {
      unsubscribeFromChatroom(chatroomId)
    }
  }

  setupSubscription() {
    if (!this.messagesTarget) return
    
    const chatroomId = this.messagesTarget.dataset.chatroomId
    if (!chatroomId) return
    
    this.subscription = createChatroomSubscription(chatroomId)
    this.subscription.received = this.#received.bind(this)
  }

  scrollToBottom() {
    if (this.messagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  resetForm() {
    if (this.hasFormTarget && this.formTarget instanceof HTMLFormElement) {
      this.formTarget.reset()
      const input = this.formTarget.querySelector("input[type='text']")
      if (input) {
        input.focus()
      }
    }
  }

  #received(data) {
    if (!data) return

    if (data.type === 'typing_status') {
      this.#handleTypingStatus(data)
    } else if (data.type === 'user_status') {
      this.#handleUserStatus(data)
    } else if (data.type === 'message_reaction') {
      this.#handleMessageReaction(data)
    } else if (data.type === 'message_update') {
      this.#handleMessageUpdate(data)
    } else if (data.type === 'delivery_status') {
      this.#handleDeliveryStatus(data)
    } else {
      if (data.html) {
        this.messageListTarget.insertAdjacentHTML('beforeend', data.html)
        this.scrollToBottom()
        if (data.message_id) {
          this.#markMessageAsDelivered(data.message_id)
        }
        this.resetForm()
      }
    }
  }

  #handleTypingStatus(data) {
    const typingIndicator = document.getElementById('typing-indicator')
    if (!typingIndicator) return

    if (data.is_typing) {
      typingIndicator.textContent = `${data.username} is typing...`
      typingIndicator.classList.remove('hidden')
    } else {
      typingIndicator.classList.add('hidden')
    }
  }

  #handleUserStatus(data) {
    const userStatus = document.querySelector(`[data-user-status="${data.user_id}"]`)
    if (!userStatus) return

    userStatus.textContent = data.status
    userStatus.classList.toggle('text-green-500', data.status === 'online')
    userStatus.classList.toggle('text-gray-500', data.status === 'offline')
  }

  #handleMessageReaction(data) {
    const messageElement = document.querySelector(`#message_${data.messageId}`)
    if (messageElement) {
      const reactionsContainer = messageElement.querySelector('.reactions')
      if (reactionsContainer) {
        reactionsContainer.outerHTML = data.reactionsHtml
      }
    }
  }

  #handleMessageUpdate(data) {
    const messageElement = document.querySelector(`#message_${data.messageId}`)
    if (messageElement) {
      messageElement.outerHTML = data.html
    }
  }

  #handleDeliveryStatus(data) {
    const messageElement = document.querySelector(`#message_${data.message_id}`)
    if (messageElement) {
      const statusElement = messageElement.querySelector('.message-status')
      if (statusElement) {
        statusElement.innerHTML = data.html
      }
    }
  }

  #markMessageAsDelivered(messageId) {
    if (!messageId) return
    
    fetch(`/messages/${messageId}/mark_delivered`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
      }
    }).catch(error => console.error('Error marking message as delivered:', error))
  }
}
