import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.filters = {
      search: "",
      language: "",
      minCondition: "",
      foilOnly: false,
      hasMatches: false
    }
  }

  search(event) {
    this.filters.search = event.target.value.toLowerCase()
    this.applyFilters()
  }

  filterByLanguage(event) {
    this.filters.language = event.target.value
    this.applyFilters()
  }

  filterByMinCondition(event) {
    this.filters.minCondition = event.target.value
    this.applyFilters()
  }

  toggleFoilFilter(event) {
    this.filters.foilOnly = !this.filters.foilOnly
    event.currentTarget.classList.toggle('bg-yellow-100')
    this.applyFilters()
  }

  toggleMatchesFilter(event) {
    this.filters.hasMatches = !this.filters.hasMatches
    event.currentTarget.classList.toggle('bg-green-100')
    this.applyFilters()
  }

  applyFilters() {
    this.cardTargets.forEach(card => {
      const cardName = card.dataset.cardName.toLowerCase()
      const cardLanguage = card.dataset.language
      const cardMinCondition = card.dataset.minCondition
      const isFoil = card.dataset.foil === 'true'
      const matchesCount = parseInt(card.dataset.matchesCount) || 0

      const matchesSearch = !this.filters.search || cardName.includes(this.filters.search)
      const matchesLanguage = !this.filters.language || cardLanguage === this.filters.language || cardLanguage === 'any'
      const matchesMinCondition = !this.filters.minCondition || cardMinCondition === this.filters.minCondition
      const matchesFoil = !this.filters.foilOnly || isFoil
      const matchesHasMatches = !this.filters.hasMatches || matchesCount > 0

      if (matchesSearch && matchesLanguage && matchesMinCondition && matchesFoil && matchesHasMatches) {
        card.classList.remove('hidden')
        card.classList.add('animate-fade-in')
      } else {
        card.classList.add('hidden')
        card.classList.remove('animate-fade-in')
      }
    })
  }
}
