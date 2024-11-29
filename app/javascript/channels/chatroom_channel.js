import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()

document.addEventListener("turbo:load", () => {
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
})
