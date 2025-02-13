import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions", "scryfallOracleId", "formFields", "extension", "loader"]
  
  connect() {
    this.suggestionsList = []
    this.selectedCard = null
    this.currentFocus = -1
    
    // Si nous sommes en mode édition, le formulaire est déjà visible
    if (this.formFieldsTarget.classList.contains('hidden') === false) {
      this.isEditing = true
      // En mode édition, on applique directement le style des extensions
      if (this.hasExtensionTarget) {
        this.styleExtensionSelect(this.extensionTarget)
      }
    }

    // Gestion des touches clavier pour la navigation
    this.inputTarget.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowDown') {
        e.preventDefault()
        this.currentFocus++
        this.addActive()
      } else if (e.key === 'ArrowUp') {
        e.preventDefault()
        this.currentFocus--
        this.addActive()
      } else if (e.key === 'Enter' && this.currentFocus > -1) {
        e.preventDefault()
        if (this.suggestionsTarget.children[this.currentFocus]) {
          this.suggestionsTarget.children[this.currentFocus].click()
        }
      } else if (e.key === 'Escape') {
        this.hideSuggestions()
      }
    })

    // Fermer les suggestions en cliquant en dehors
    document.addEventListener('click', (e) => {
      if (!this.element.contains(e.target)) {
        this.hideSuggestions()
      }
    })
  }

  addActive() {
    if (!this.suggestionsTarget.children) return
    
    // Réinitialiser tous les éléments
    Array.from(this.suggestionsTarget.children).forEach(item => {
      item.classList.remove('bg-indigo-50', 'border-l-4', 'border-indigo-500')
    })

    // Ajuster l'index si nécessaire
    if (this.currentFocus >= this.suggestionsTarget.children.length) this.currentFocus = 0
    if (this.currentFocus < 0) this.currentFocus = (this.suggestionsTarget.children.length - 1)

    // Ajouter la classe active
    if (this.suggestionsTarget.children[this.currentFocus]) {
      this.suggestionsTarget.children[this.currentFocus].classList.add('bg-indigo-50', 'border-l-4', 'border-indigo-500')
      this.suggestionsTarget.children[this.currentFocus].scrollIntoView({ block: 'nearest' })
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

    // Afficher l'indicateur de chargement
    this.loaderTarget.classList.remove('hidden')
    
    try {
      const response = await fetch(`/cards/search?query=${encodeURIComponent(query)}`)
      this.suggestionsList = await response.json()
      if (this.suggestionsList.length > 0) {
        this.showSuggestions()
      } else {
        this.showNoResults()
      }
    } catch (error) {
      console.error("Erreur lors de la recherche:", error)
      this.hideSuggestions()
    } finally {
      this.loaderTarget.classList.add('hidden')
    }
  }

  showSuggestions() {
    // Ne pas afficher les suggestions en mode édition
    if (this.isEditing) return
    
    this.suggestionsTarget.innerHTML = this.suggestionsList.map((card, index) => {
      // Prendre la première version de la carte qui a une image
      const cardVersion = card.card_versions?.find(v => v.img_uri) || card.card_versions?.[0]
      
      return `
        <div class="suggestion-item p-4 hover:bg-indigo-50 cursor-pointer transition-all duration-200 flex items-center gap-4 border-b border-gray-100 last:border-b-0"
             data-action="click->autocomplete#selectCard"
             data-card-index="${index}">
          <div class="w-12 h-16 flex-shrink-0 bg-gray-100 rounded overflow-hidden">
            ${cardVersion?.img_uri ? `
              <img src="${cardVersion.img_uri}" 
                   alt="${card.name_fr}" 
                   class="w-full h-full object-cover"
                   loading="lazy">
            ` : `
              <div class="w-full h-full flex items-center justify-center">
                <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
            `}
          </div>
          <div class="flex-grow min-w-0">
            <div class="font-medium text-gray-900 truncate">${card.name_fr}</div>
            <div class="text-sm text-gray-500 truncate">${card.name_en}</div>
          </div>
          <div class="text-indigo-600 flex-shrink-0">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </div>
        </div>
      `
    }).join('')
    
    this.suggestionsTarget.classList.remove('hidden')
  }

  showNoResults() {
    this.suggestionsTarget.innerHTML = `
      <div class="p-4 text-center text-gray-500">
        <svg class="w-6 h-6 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        Aucune carte trouvée
      </div>
    `
    this.suggestionsTarget.classList.remove('hidden')
  }

  hideSuggestions() {
    this.currentFocus = -1
    this.suggestionsTarget.classList.add('hidden')
    this.suggestionsTarget.innerHTML = ''
  }

  async selectCard(event) {
    if (this.isEditing) return
    const index = event.currentTarget.dataset.cardIndex
    this.selectedCard = this.suggestionsList[index]
    
    // Mettre à jour l'input avec le nom de la carte
    this.inputTarget.value = this.selectedCard.name_fr

    // Reset form fields when selecting a new card
    if (this.hasExtensionTarget) {
      this.extensionTarget.innerHTML = ''
      const existingWrapper = this.extensionTarget.closest('.relative')
      if (existingWrapper) {
        existingWrapper.parentNode.insertBefore(this.extensionTarget, existingWrapper)
        existingWrapper.remove()
      }
    }
    
    // Déterminer le type de formulaire
    const formType = this.element.dataset.autocompleteTypeValue
    
    // Gérer différemment selon le type de formulaire
    if (formType === 'wanted') {
      // Pour les wants, on utilise l'oracle_id pour le scryfall_id
      this.scryfallOracleIdTarget.value = this.selectedCard.oracle_id
      
      // Mettre à jour le card_id caché
      const cardIdInput = this.element.querySelector('input[name="user_wanted_card[card_id]"]')
      if (cardIdInput) {
        cardIdInput.value = this.selectedCard.id
      }
      
      if (this.hasExtensionTarget) {
        try {
          const response = await fetch(`/cards/versions?oracle_id=${this.selectedCard.oracle_id}`)
          const versions = await response.json()
          if (versions && versions.length > 0) {
            this.updateExtensionSelect(versions, true)
          }
        } catch (error) {
          console.error("Erreur lors de la récupération des versions:", error)
        }
      }
    } else if (formType === 'collection' && this.hasExtensionTarget) {
      try {
        // Pour la collection, on utilise aussi l'oracle_id pour récupérer les versions
        const response = await fetch(`/cards/versions?oracle_id=${this.selectedCard.oracle_id}`)
        const versions = await response.json()
        if (versions && versions.length > 0) {
          this.updateExtensionSelect(versions, false)
          // Mettre à jour le scryfall_id avec l'ID de la version sélectionnée
          this.scryfallOracleIdTarget.value = this.selectedCard.oracle_id
        }
      } catch (error) {
        console.error("Erreur lors de la récupération des versions:", error)
      }
    }

    // Afficher le formulaire
    this.formFieldsTarget.classList.remove('hidden')
    
    this.hideSuggestions()
  }

  updateExtensionSelect(versions, isWanted) {
    const select = this.extensionTarget
    select.innerHTML = ''

    if (isWanted) {
      const defaultOption = document.createElement('option')
      defaultOption.value = ''
      defaultOption.textContent = "N'importe quelle extension"
      select.appendChild(defaultOption)
    }

    versions.forEach(version => {
      const option = document.createElement('option')
      option.value = version.id
      option.textContent = version.extension.name
      option.dataset.iconUri = version.extension.icon_uri
      select.appendChild(option)
    })

    this.styleExtensionSelect(select)
  }

  styleExtensionSelect(select) {
    // Remove existing wrapper if it exists
    const existingWrapper = select.closest('.relative')
    if (existingWrapper) {
      // Move the select back to its original position
      existingWrapper.parentNode.insertBefore(select, existingWrapper)
      existingWrapper.remove()
    }

    const wrapper = document.createElement('div')
    wrapper.className = 'relative'
    select.parentNode.insertBefore(wrapper, select)
    wrapper.appendChild(select)

    // Créer l'affichage personnalisé
    const display = document.createElement('div')
    display.className = 'flex items-center gap-2 px-6 py-4 border border-gray-300 rounded-lg shadow-sm bg-white cursor-pointer'
    
    // Mettre à jour l'affichage en fonction de l'option sélectionnée
    const updateDisplay = () => {
      const selectedOption = select.options[select.selectedIndex]
      const iconUri = selectedOption?.dataset?.iconUri

      display.innerHTML = `
        <div class="flex items-center gap-2 flex-grow">
          ${iconUri ? `<img src="${iconUri}" alt="" class="w-5 h-5 object-contain">` : ''}
          <span class="text-gray-700">${selectedOption?.textContent || 'Sélectionnez une extension'}</span>
        </div>
        <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      `
    }

    // Créer la liste déroulante
    const dropdown = document.createElement('div')
    dropdown.className = 'absolute w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg hidden z-50 max-h-60 overflow-y-auto'
    
    // Ajouter les options à la liste déroulante
    Array.from(select.options).forEach((option, index) => {
      const item = document.createElement('div')
      item.className = 'flex items-center gap-2 px-6 py-3 hover:bg-gray-50 cursor-pointer'
      const iconUri = option.dataset?.iconUri

      item.innerHTML = `
        ${iconUri ? `<img src="${iconUri}" alt="" class="w-5 h-5 object-contain">` : ''}
        <span class="text-gray-700">${option.textContent}</span>
      `

      item.addEventListener('click', () => {
        select.selectedIndex = index
        updateDisplay()
        dropdown.classList.add('hidden')
      })

      dropdown.appendChild(item)
    })

    // Gérer l'affichage/masquage de la liste déroulante
    display.addEventListener('click', (e) => {
      e.stopPropagation()
      dropdown.classList.toggle('hidden')
    })

    document.addEventListener('click', () => {
      dropdown.classList.add('hidden')
    })

    // Cacher le select original
    select.style.display = 'none'
    
    // Ajouter les éléments au DOM
    wrapper.appendChild(display)
    wrapper.appendChild(dropdown)

    // Initialiser l'affichage
    updateDisplay()

    // Mettre à jour l'affichage quand la valeur change
    select.addEventListener('change', updateDisplay)
  }
}
