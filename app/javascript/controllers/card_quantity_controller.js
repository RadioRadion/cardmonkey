import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "increment", "decrement"]
  static values = {
    max: Number,
    current: Number,
    price: Number
  }

  connect() {
    this.currentValue = 0
    this.updateButtonStates()
  }

  increment() {
    if (this.currentValue < this.maxValue) {
      this.currentValue++
      this.updateDisplay()
    }
    this.updateButtonStates()
  }

  decrement() {
    if (this.currentValue > 0) {
      this.currentValue--
      this.updateDisplay()
    }
    this.updateButtonStates()
  }

  updateDisplay() {
    this.quantityTarget.textContent = this.currentValue
    
    // Émettre un événement personnalisé avec toutes les informations nécessaires
    const event = new CustomEvent("card-quantity:changed", {
      bubbles: true,
      detail: {
        cardId: this.element.dataset.cardId,
        side: this.element.dataset.side,
        quantity: this.currentValue,
        price: this.priceValue || 0
      }
    })
    this.element.dispatchEvent(event)
  }

  updateButtonStates() {
    this.incrementTarget.disabled = this.currentValue >= this.maxValue
    this.decrementTarget.disabled = this.currentValue <= 0

    // Mise à jour visuelle des boutons
    this.incrementTarget.classList.toggle("opacity-50", this.currentValue >= this.maxValue)
    this.decrementTarget.classList.toggle("opacity-50", this.currentValue <= 0)
  }
}
