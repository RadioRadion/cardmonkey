import consumer from "./consumer"

const ChatroomSubscription = {
  initialize() {
    this.setupChatroom()
    this.setupTypingIndicator()
  },

  setupChatroom() {
    const messagesContainer = document.getElementById('messages')
    if (!messagesContainer) return

    const chatroomId = messagesContainer.dataset.chatroomId
    
    consumer.subscriptions.create(
      { channel: "ChatroomChannel", id: chatroomId },
      {
        connected() {
          console.log("Connected to chatroom channel")
        },

        disconnected() {
          console.log("Disconnected from chatroom channel")
        },

        received(data) {
          if (data.type === 'typing_status') {
            this.handleTypingStatus(data)
          } else if (data.type === 'user_status') {
            this.handleUserStatus(data)
          } else {
            messagesContainer.insertAdjacentHTML('beforeend', data)
            this.scrollToBottom()
          }
        },

        handleTypingStatus(data) {
          const typingIndicator = document.getElementById('typing-indicator')
          if (!typingIndicator) return

          if (data.is_typing) {
            typingIndicator.textContent = `${data.username} is typing...`
            typingIndicator.classList.remove('hidden')
          } else {
            typingIndicator.classList.add('hidden')
          }
        },

        handleUserStatus(data) {
          const userStatus = document.querySelector(`[data-user-status="${data.user_id}"]`)
          if (!userStatus) return

          userStatus.textContent = data.status
          userStatus.classList.toggle('text-green-500', data.status === 'online')
          userStatus.classList.toggle('text-gray-500', data.status === 'offline')
        },

        scrollToBottom() {
          const messages = document.getElementById('messages')
          if (messages) {
            messages.scrollTop = messages.scrollHeight
          }
        }
      }
    )
  },

  setupTypingIndicator() {
    let typingTimer
    const messageInput = document.getElementById('message_content')
    if (!messageInput) return

    const chatroomId = document.getElementById('messages').dataset.chatroomId
    const subscription = consumer.subscriptions.create(
      { channel: "ChatroomChannel", id: chatroomId },
      {}
    )

    messageInput.addEventListener('input', () => {
      clearTimeout(typingTimer)
      subscription.perform('typing', { typing: true })

      typingTimer = setTimeout(() => {
        subscription.perform('typing', { typing: false })
      }, 1000)
    })
  }
}

document.addEventListener('turbo:load', () => {
  ChatroomSubscription.initialize()
})

export default ChatroomSubscription
