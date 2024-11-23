import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "increment", "decrement", "selectionBadge"]
  static values = {
    max: Number,
    current: Number,
    price: Number,
    selected: { type: Boolean, default: false }
  }

  connect() {
    // Initialize with 1 if selected, 0 otherwise
    this.currentValue = this.selectedValue ? 1 : 0
    
    // Update the display and trigger the event if selected
    if (this.selectedValue) {
      this.updateDisplay()
    }
    
    this.updateButtonStates()
    this.updateSelectionBadge()
  }

  increment() {
    if (this.currentValue < this.maxValue) {
      this.currentValue++
      this.updateDisplay()
    }
    this.updateButtonStates()
    this.updateSelectionBadge()
  }

  decrement() {
    if (this.currentValue > 0) {
      this.currentValue--
      this.updateDisplay()
    }
    this.updateButtonStates()
    this.updateSelectionBadge()
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
        price: parseFloat(this.priceValue) || 0
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

  updateSelectionBadge() {
    if (this.hasSelectionBadgeTarget) {
      this.selectionBadgeTarget.classList.toggle("hidden", this.currentValue === 0)
    }
  }
}
