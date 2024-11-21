import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messageList"]

  connect() {
    this.scrollToBottom()
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
