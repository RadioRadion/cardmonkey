import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions", "scryfallOracleId", "formFields", "extension"]

  connect() {
    this.suggestionsList = []
    this.selectedCard = null

    // Si nous sommes en mode édition, le formulaire est déjà visible
    if (this.formFieldsTarget.classList.contains('hidden') === false) {
      this.isEditing = true
    }
  }

  async search(event) {
    // Ne pas rechercher en mode édition
    if (this.isEditing) return

    const query = event.target.value
    if (query.length < 3) {
      this.hideSuggestions()
      return
    }

    try {
      const response = await fetch(`/cards/search?query=${encodeURIComponent(query)}`)
      this.suggestionsList = await response.json()
      this.showSuggestions()
    } catch (error) {
      console.error("Erreur lors de la recherche:", error)
    }
  }

  showSuggestions() {
    // Ne pas afficher les suggestions en mode édition
    if (this.isEditing) return

    this.suggestionsTarget.innerHTML = this.suggestionsList.map((card, index) => `
      <div class="suggestion-item p-2 hover:bg-gray-100 cursor-pointer"
           data-action="click->autocomplete#selectCard"
           data-card-index="${index}">
        ${card.name_fr} - ${card.name_en}
      </div>
    `).join('')
    this.suggestionsTarget.classList.remove('hidden')
  }

  hideSuggestions() {
    this.suggestionsTarget.innerHTML = ''
    this.suggestionsTarget.classList.add('hidden')
  }

  async selectCard(event) {
    // Ne pas gérer la sélection en mode édition
    if (this.isEditing) return

    const index = event.currentTarget.dataset.cardIndex
    this.selectedCard = this.suggestionsList[index]
    
    // Mettre à jour l'input avec le nom de la carte
    this.inputTarget.value = `${this.selectedCard.name_fr} - ${this.selectedCard.name_en}`
    
    // Récupérer les versions de la carte
    try {
      const response = await fetch(`/cards/versions?oracle_id=${this.selectedCard.oracle_id}`)
      const versions = await response.json()
      
      if (versions && versions.length > 0) {
        // Afficher le reste du formulaire
        this.formFieldsTarget.classList.remove('hidden')
        
        // Mettre à jour les versions de carte dans le select
        this.updateCardVersions(versions)
      }
    } catch (error) {
      console.error("Erreur lors de la récupération des versions:", error)
    }
    
    this.hideSuggestions()
  }

  updateCardVersions(versions) {
    // Ne pas mettre à jour les versions en mode édition
    if (this.isEditing) return

    const select = this.extensionTarget
    select.innerHTML = versions.map(version => `
      <option value="${version.id}">
        ${version.extension.name} - ${version.extension.code}
      </option>
    `).join('')
  }
}
