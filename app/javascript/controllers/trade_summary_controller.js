// app/javascript/controllers/trade_summary_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "userCardCount", "userTotalValue",
    "partnerCardCount", "partnerTotalValue",
    "differenceValue", "submitButton", "status"
  ]

  static values = {
    userCards: { type: Array, default: [] },
    partnerCards: { type: Array, default: [] }
  }

  connect() {
    this.updateSummary()
  }

  updateSummary() {
    const userTotal = this.calculateTotal(this.userCardsValue)
    const partnerTotal = this.calculateTotal(this.partnerCardsValue)
    const difference = userTotal - partnerTotal

    // Mise à jour des compteurs
    this.userCardCountTarget.textContent = this.userCardsValue.length
    this.partnerCardCountTarget.textContent = this.partnerCardsValue.length

    // Mise à jour des valeurs
    this.userTotalValueTarget.textContent = this.formatPrice(userTotal)
    this.partnerTotalValueTarget.textContent = this.formatPrice(partnerTotal)
    this.differenceValueTarget.textContent = this.formatPrice(Math.abs(difference))

    // Mise à jour visuelle
    this.updateDifferenceDisplay(difference)
    this.updateTradeStatus(difference)
    this.updateSubmitButton()
  }

  calculateTotal(cards) {
    return cards.reduce((sum, card) => sum + (card.price * card.quantity), 0)
  }

  formatPrice(value) {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR'
    }).format(value)
  }

  updateDifferenceDisplay(difference) {
    const target = this.differenceValueTarget
    target.classList.remove('text-green-600', 'text-red-600', 'text-blue-600')

    if (difference === 0) {
      target.classList.add('text-green-600')
    } else if (difference > 0) {
      target.classList.add('text-red-600')
    } else {
      target.classList.add('text-blue-600')
    }
  }

  updateTradeStatus(difference) {
    const hasCards = this.userCardsValue.length > 0 || this.partnerCardsValue.length > 0
    
    if (!hasCards) {
      this.statusTarget.textContent = "Sélectionnez des cartes pour l'échange"
      this.statusTarget.className = "text-sm text-gray-600"
    } else if (difference === 0) {
      this.statusTarget.textContent = "Échange équilibré ✓"
      this.statusTarget.className = "text-sm text-green-600"
    } else {
      const text = difference > 0 ? "Vous donnez plus" : "Vous recevez plus"
      this.statusTarget.textContent = text
      this.statusTarget.className = "text-sm text-yellow-600"
    }
  }

  updateSubmitButton() {
    const hasCards = this.userCardsValue.length > 0 || this.partnerCardsValue.length > 0
    this.submitButtonTarget.disabled = !hasCards
  }
}