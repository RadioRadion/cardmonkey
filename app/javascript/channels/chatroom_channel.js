import consumer from "./consumer"

const chatrooms = {}

// Function to create a new subscription for a chatroom
const createChatroomSubscription = (chatroomId) => {
  if (chatrooms[chatroomId]) {
    console.log(`Already subscribed to chatroom ${chatroomId}`)
    return chatrooms[chatroomId]
  }

  console.log(`Creating subscription for chatroom ${chatroomId}`)
  
  const subscription = consumer.subscriptions.create(
    {
      channel: "ChatroomChannel",
      id: chatroomId
    },
    {
      connected() {
        console.log(`Connected to chatroom ${chatroomId}`)
      },

      disconnected() {
        console.log(`Disconnected from chatroom ${chatroomId}`)
        delete chatrooms[chatroomId]
      },

      rejected() {
        console.log(`Subscription rejected for chatroom ${chatroomId}`)
        delete chatrooms[chatroomId]
      },

      received(data) {
        console.log(`Received data for chatroom ${chatroomId}:`, data)
      }
    }
  )

  chatrooms[chatroomId] = subscription
  return subscription
}

// Function to unsubscribe from a chatroom
const unsubscribeFromChatroom = (chatroomId) => {
  if (chatrooms[chatroomId]) {
    chatrooms[chatroomId].unsubscribe()
    delete chatrooms[chatroomId]
    console.log(`Unsubscribed from chatroom ${chatroomId}`)
  }
}

export { createChatroomSubscription, unsubscribeFromChatroom }
