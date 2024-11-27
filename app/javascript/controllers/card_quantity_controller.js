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

    // Ajouter des gestionnaires d'événements pour le clavier
    this.element.addEventListener('keydown', this.handleKeydown.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('keydown', this.handleKeydown.bind(this))
  }

  handleKeydown(event) {
    if (event.key === 'ArrowUp') {
      event.preventDefault()
      this.increment()
    } else if (event.key === 'ArrowDown') {
      event.preventDefault()
      this.decrement()
    }
  }

  increment() {
    if (this.currentValue < this.maxValue) {
      this.currentValue++
      this.updateDisplay()
      this.updateButtonStates()
      this.updateSelectionBadge()
      this.element.classList.add('ring-2', 'ring-blue-500')
    }
  }

  decrement() {
    if (this.currentValue > 0) {
      this.currentValue--
      this.updateDisplay()
      this.updateButtonStates()
      this.updateSelectionBadge()
      if (this.currentValue === 0) {
        this.element.classList.remove('ring-2', 'ring-blue-500')
      }
    }
  }

  updateDisplay() {
    this.quantityTarget.textContent = this.currentValue
    
    // Émettre un événement personnalisé avec toutes les informations nécessaires
    const cardQuantityEvent = new CustomEvent("cardQuantityChanged", {
      bubbles: true,
      detail: {
        cardId: this.element.dataset.cardId,
        side: this.element.dataset.side,
        quantity: this.currentValue,
        price: parseFloat(this.priceValue) || 0,
        name: this.element.dataset.cardName,
        set: this.element.dataset.cardSet
      }
    })
    this.element.dispatchEvent(cardQuantityEvent)
  }

  updateButtonStates() {
    // Mise à jour de l'état des boutons
    const isMaxed = this.currentValue >= this.maxValue
    const isZero = this.currentValue <= 0

    // Désactiver/activer les boutons
    this.incrementTarget.disabled = isMaxed
    this.decrementTarget.disabled = isZero

    // Mise à jour visuelle des boutons
    this.incrementTarget.classList.toggle("opacity-50", isMaxed)
    this.incrementTarget.classList.toggle("cursor-not-allowed", isMaxed)
    this.decrementTarget.classList.toggle("opacity-50", isZero)
    this.decrementTarget.classList.toggle("cursor-not-allowed", isZero)

    // Ajouter un titre pour l'accessibilité
    this.incrementTarget.title = isMaxed ? "Quantité maximale atteinte" : "Augmenter la quantité"
    this.decrementTarget.title = isZero ? "Quantité minimale atteinte" : "Diminuer la quantité"
  }

  updateSelectionBadge() {
    if (this.hasSelectionBadgeTarget) {
      const isSelected = this.currentValue > 0
      this.selectionBadgeTarget.classList.toggle("hidden", !isSelected)
      
      // Animation du badge
      if (isSelected) {
        this.selectionBadgeTarget.classList.add("scale-110")
        setTimeout(() => {
          this.selectionBadgeTarget.classList.remove("scale-110")
        }, 200)
      }
    }
  }
}
