import consumer from "./consumer";
import scroll from "./scroll"

const messagesContainer = document.getElementById('messages');
if (messagesContainer) {
  const id = messagesContainer.dataset.chatroomId;

  consumer.subscriptions.create({ channel: "ChatroomChannel", id: id }, {
    received(data) {
      messagesContainer.insertAdjacentHTML('beforeend', data); // called when data is broadcast in the cable
    }
  });
}