import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messageList"]

  connect() {
    // Initial scroll to bottom when the chat loads
    setTimeout(() => {
      this.scrollToBottom()
    }, 100)
    
    this.setupAutoScroll()
  }

  scrollToBottom() {
    const messageList = this.messageListTarget
    messageList.scrollTop = messageList.scrollHeight
  }

  setupAutoScroll() {
    const observer = new MutationObserver(() => {
      this.scrollToBottom()
    })

    observer.observe(this.messageListTarget, {
      childList: true,
      subtree: true
    })
  }
}
