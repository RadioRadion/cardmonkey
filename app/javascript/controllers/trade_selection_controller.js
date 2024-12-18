import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "userCardCount", 
    "partnerCardCount", 
    "userValue", 
    "partnerValue", 
    "balance",
    "submitButton",
    "userCardsGrid",
    "partnerCardsGrid"
  ]

  connect() {
    this.userCards = new Map() // cardId -> {quantity, price}
    this.partnerCards = new Map()
    this.partnerId = this.element.dataset.tradeSelectionPartnerIdValue
    
    // Écouter les changements de quantité
    this.element.addEventListener("cardQuantityChanged", this.handleQuantityChange.bind(this))

    // Initialize pre-selected cards
    this.initializePreselectedCards()
  }

  disconnect() {
    this.element.removeEventListener("cardQuantityChanged", this.handleQuantityChange.bind(this))
  }

  initializePreselectedCards() {
    // Process pre-selected user cards
    this.element.querySelectorAll('[data-side="user"][data-card-quantity-selected-value="true"]').forEach(card => {
      const cardId = parseInt(card.dataset.cardId)
      const price = parseFloat(card.dataset.cardQuantityPriceValue) || 0
      this.userCards.set(cardId, { quantity: 1, price })
    })

    // Process pre-selected partner cards
    this.element.querySelectorAll('[data-side="partner"][data-card-quantity-selected-value="true"]').forEach(card => {
      const cardId = parseInt(card.dataset.cardId)
      const price = parseFloat(card.dataset.cardQuantityPriceValue) || 0
      this.partnerCards.set(cardId, { quantity: 1, price })
    })

    // Update totals after processing pre-selected cards
    this.updateTotals()
  }

  handleQuantityChange(event) {
    const { cardId, side, quantity, price } = event.detail
    const cards = side === 'user' ? this.userCards : this.partnerCards

    if (quantity === 0) {
      cards.delete(cardId)
    } else {
      cards.set(cardId, { quantity, price })
    }

    this.updateTotals()
  }

  updateTotals() {
    // Calcul des totaux
    const userTotal = this.calculateTotal(this.userCards)
    const partnerTotal = this.calculateTotal(this.partnerCards)
    const balance = userTotal - partnerTotal

    // Mise à jour de l'affichage des cartes
    this.userCardCountTarget.textContent = this.getTotalQuantity(this.userCards)
    this.partnerCardCountTarget.textContent = this.getTotalQuantity(this.partnerCards)
    
    // Mise à jour des valeurs
    this.userValueTarget.textContent = this.formatPrice(userTotal)
    this.partnerValueTarget.textContent = this.formatPrice(partnerTotal)
    
    // Mise à jour de la balance avec couleur
    this.balanceTarget.textContent = this.formatPrice(Math.abs(balance))
    this.balanceTarget.classList.remove('text-green-600', 'text-red-600', 'text-gray-600')
    
    if (balance > 0) {
      this.balanceTarget.classList.add('text-red-600')
      this.balanceTarget.textContent = `+${this.formatPrice(balance)} (défavorable)`
    } else if (balance < 0) {
      this.balanceTarget.classList.add('text-green-600')
      this.balanceTarget.textContent = `+${this.formatPrice(-balance)} (favorable)`
    } else {
      this.balanceTarget.classList.add('text-gray-600')
      this.balanceTarget.textContent = this.formatPrice(0)
    }

    // Activer/désactiver le bouton de soumission
    const hasCards = this.userCards.size > 0 || this.partnerCards.size > 0
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = !hasCards
    }
  }

  calculateTotal(cards) {
    return Array.from(cards.values())
      .reduce((total, { quantity, price }) => total + (quantity * price), 0)
  }

  getTotalQuantity(cards) {
    return Array.from(cards.values())
      .reduce((total, { quantity }) => total + quantity, 0)
  }

  formatPrice(amount) {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR',
      minimumFractionDigits: 2
    }).format(amount)
  }

  search(event) {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }

    const query = event.target.value.trim()
    const side = event.target.name === 'user_query' ? 'user' : 'partner'
    const minLength = 3

    // Si le champ est vide, on recharge toutes les cartes
    if (query === '') {
      this.searchTimeout = setTimeout(() => {
        this.performSearch(side, '')
      }, 100)
      return
    }

    // Si la recherche a moins de 3 caractères, on ne fait rien
    if (query.length < minLength) {
      return
    }

    // Recherche normale avec 3 caractères ou plus
    this.searchTimeout = setTimeout(() => {
      this.performSearch(side, query)
    }, 300)
  }

  async performSearch(side, query) {
    try {
      const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
      const response = await fetch(`/trades/search_cards?query=${encodeURIComponent(query)}&side=${side}&partner_id=${this.partnerId}`, {
        headers: {
          'X-CSRF-Token': csrfToken,
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin'
      })
      
      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`)
      }
      
      const html = await response.text()
      const target = side === 'user' ? this.userCardsGridTarget : this.partnerCardsGridTarget
      target.innerHTML = html

      // Re-initialize pre-selected cards after search
      this.initializePreselectedCards()
    } catch (error) {
      console.error('Erreur lors de la recherche:', error)
    }
  }

  submitTrade(event) {
    if (this.userCards.size === 0 && this.partnerCards.size === 0) {
      event.preventDefault()
      alert("Veuillez sélectionner au moins une carte pour l'échange")
      return
    }

    const form = event.target
    
    // Préparation des cartes pour la soumission
    const offerCards = this.formatCardsForSubmission(this.userCards)
    const targetCards = this.formatCardsForSubmission(this.partnerCards)

    // Mise à jour des champs cachés
    form.querySelector('input[name="trade[offer]"]').value = offerCards
    form.querySelector('input[name="trade[target]"]').value = targetCards
  }

  formatCardsForSubmission(cards) {
    return Array.from(cards.entries())
      .map(([cardId, { quantity }]) => Array(quantity).fill(cardId))
      .flat()
      .join(',')
  }
}
