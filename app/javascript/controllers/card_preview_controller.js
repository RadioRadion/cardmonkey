// app/javascript/controllers/card_preview_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "name", "set", "price", "info"]

  connect() {
    // Initialize observer for cards
    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersection(entries),
      { threshold: 0.1 }
    )
    
    this.observeCards()
  }

  observeCards() {
    document.querySelectorAll('[data-card-preview="true"]').forEach(card => {
      this.observer.observe(card)
    })
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        this.setupHoverListeners(entry.target)
      }
    })
  }

  setupHoverListeners(card) {
    card.addEventListener('mouseenter', (e) => this.showPreview(e))
    card.addEventListener('mousemove', (e) => this.movePreview(e))
    card.addEventListener('mouseleave', () => this.hidePreview())
  }

  showPreview(event) {
    const card = event.currentTarget
    const data = card.dataset

    this.element.classList.remove('hidden')
    this.imageTarget.src = data.previewImage
    this.nameTarget.textContent = data.cardName
    this.setTarget.textContent = data.cardSet
    this.priceTarget.textContent = data.cardPrice

    this.movePreview(event)
  }

  movePreview(event) {
    const preview = this.element
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    const previewRect = preview.getBoundingClientRect()
    
    let x = event.clientX + 20
    let y = event.clientY + 20

    // Adjust position if preview would go off screen
    if (x + previewRect.width > viewportWidth) {
      x = event.clientX - previewRect.width - 20
    }
    if (y + previewRect.height > viewportHeight) {
      y = viewportHeight - previewRect.height - 20
    }

    preview.style.transform = `translate(${x}px, ${y}px)`
  }

  hidePreview() {
    this.element.classList.add('hidden')
  }
}