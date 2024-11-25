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
      if (this.suggestionsList.length > 0) {
        this.showSuggestions()
      } else {
        this.hideSuggestions()
      }
    } catch (error) {
      console.error("Erreur lors de la recherche:", error)
      this.hideSuggestions()
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
    this.suggestionsTarget.classList.add('hidden')
    this.suggestionsTarget.innerHTML = ''
  }

  async selectCard(event) {
    if (this.isEditing) return
    const index = event.currentTarget.dataset.cardIndex
    this.selectedCard = this.suggestionsList[index]
    
    // Mettre à jour l'input avec le nom de la carte
    this.inputTarget.value = `${this.selectedCard.name_fr} - ${this.selectedCard.name_en}`
    
    // Déterminer le type de formulaire
    const formType = this.element.dataset.autocompleteTypeValue
    
    // Gérer différemment selon le type de formulaire
    if (formType === 'wanted') {
      // Pour user_wanted_card, on utilise l'oracle_id
      this.scryfallOracleIdTarget.value = this.selectedCard.oracle_id
      
      // Charger les versions
      if (this.hasExtensionTarget) {
        try {
          const response = await fetch(`/cards/versions?oracle_id=${this.selectedCard.oracle_id}`)
          const versions = await response.json()
          if (versions && versions.length > 0) {
            this.updateWantedVersions(versions)
          }
        } catch (error) {
          console.error("Erreur lors de la récupération des versions:", error)
        }
      }
    }

    // Ne récupérer les versions que pour le formulaire de collection
    if (formType === 'collection' && this.hasExtensionTarget) {
      try {
        const response = await fetch(`/cards/versions?oracle_id=${this.selectedCard.oracle_id}`)
        const versions = await response.json()
        if (versions && versions.length > 0) {
          this.updateCardVersions(versions)
          // Pour user_card, on utilise le scryfall_id de la version
          this.scryfallOracleIdTarget.value = versions[0].scryfall_id
        }
      } catch (error) {
        console.error("Erreur lors de la récupération des versions:", error)
      }
    }

    this.formFieldsTarget.classList.remove('hidden')
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

  updateWantedVersions(versions) {
    // Ne pas mettre à jour les versions en mode édition
    if (this.isEditing) return
    const select = this.extensionTarget
    select.innerHTML = `
      <option value="">N'importe quelle extension</option>
      ${versions.map(version => `
        <option value="${version.id}">
          ${version.extension.name} - ${version.extension.code}
        </option>
      `).join('')}
    `
  }
}
