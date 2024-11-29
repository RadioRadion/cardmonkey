import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"
import debounce from "lodash/debounce"

export default class extends Controller {
  static targets = ["messages", "messageList", "input", "form"]
  static values = {
    loading: Boolean,
    page: Number,
    lastMessageId: Number
  }

  connect() {
    this.setupSubscription()
    this.setupInfiniteScroll()
    this.setupTypingIndicator()
    this.#scrollToBottom()
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
    this.intersectionObserver?.disconnect()
  }

  // Remove the custom form submission as we'll let Turbo handle it
  resetForm() {
    if (this.hasFormTarget) {
      this.formTarget.reset()
      this.#scrollToBottom()
    }
  }

  setupSubscription() {
    this.channel = createConsumer().subscriptions.create(
      { 
        channel: "ChatroomChannel",
        id: this.messagesTarget.dataset.chatroomId
      },
      {
        received: this.#received.bind(this),
        connected: this.#connected.bind(this),
        disconnected: this.#disconnected.bind(this)
      }
    )
  }

  setupInfiniteScroll() {
    const options = {
      root: this.messagesTarget,
      rootMargin: '0px',
      threshold: 0.1
    }

    this.intersectionObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.loadingValue) {
          this.loadMoreMessages()
        }
      })
    }, options)

    const firstMessage = this.messagesTarget.firstElementChild
    if (firstMessage) {
      this.intersectionObserver.observe(firstMessage)
    }
  }

  setupTypingIndicator() {
    this.debouncedTyping = debounce(() => {
      this.channel.perform('typing', { typing: false })
    }, 1000)

    if (this.hasInputTarget) {
      this.inputTarget.addEventListener('input', () => {
        this.channel.perform('typing', { typing: true })
        this.debouncedTyping()
      })
    }
  }

  async loadMoreMessages() {
    if (this.loadingValue) return

    this.loadingValue = true
    const nextPage = (this.pageValue || 1) + 1
    
    try {
      const response = await fetch(`/messages?page=${nextPage}&chatroom_id=${this.messagesTarget.dataset.chatroomId}`)
      const html = await response.text()
      
      if (html.trim()) {
        this.messagesTarget.insertAdjacentHTML('afterbegin', html)
        this.pageValue = nextPage
        
        // Re-observe the new first message for infinite scroll
        const firstMessage = this.messagesTarget.firstElementChild
        if (firstMessage) {
          this.intersectionObserver.observe(firstMessage)
        }
      }
    } catch (error) {
      console.error('Error loading messages:', error)
    } finally {
      this.loadingValue = false
    }
  }

  #received(data) {
    if (data.type === 'typing_status') {
      this.#handleTypingStatus(data)
    } else if (data.type === 'user_status') {
      this.#handleUserStatus(data)
    } else if (data.type === 'message_reaction') {
      this.#handleMessageReaction(data)
    } else if (data.type === 'message_update') {
      this.#handleMessageUpdate(data)
    } else {
      const shouldScroll = this.#isScrolledToBottom()
      this.messageListTarget.insertAdjacentHTML('beforeend', data.html)
      if (shouldScroll) {
        this.#scrollToBottom()
      }
      this.#markMessageAsDelivered(data.messageId)
    }
  }

  #connected() {
    console.log("Connected to chatroom channel")
    this.#updateConnectionStatus('online')
  }

  #disconnected() {
    console.log("Disconnected from chatroom channel")
    this.#updateConnectionStatus('offline')
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

  #markMessageAsDelivered(messageId) {
    if (!messageId) return
    
    fetch(`/messages/${messageId}/mark_delivered`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
      }
    }).catch(error => console.error('Error marking message as delivered:', error))
  }

  #updateConnectionStatus(status) {
    fetch('/users/update_status', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
      },
      body: JSON.stringify({ status })
    }).catch(error => console.error('Error updating connection status:', error))
  }

  #isScrolledToBottom() {
    const { scrollTop, scrollHeight, clientHeight } = this.messagesTarget
    return Math.abs(scrollHeight - clientHeight - scrollTop) < 10
  }

  #scrollToBottom() {
    if (this.messagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }
}
