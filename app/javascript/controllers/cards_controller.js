import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.filters = {
      search: "",
      language: "",
      condition: "",
      foilOnly: false
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

  filterByCondition(event) {
    this.filters.condition = event.target.value
    this.applyFilters()
  }

  toggleFoilFilter(event) {
    this.filters.foilOnly = !this.filters.foilOnly
    event.currentTarget.classList.toggle('bg-yellow-100')
    this.applyFilters()
  }

  applyFilters() {
    this.cardTargets.forEach(card => {
      const cardName = card.dataset.cardName.toLowerCase()
      const cardLanguage = card.dataset.language
      const cardCondition = card.dataset.condition
      const isFoil = card.dataset.foil === 'true'

      const matchesSearch = !this.filters.search || cardName.includes(this.filters.search)
      const matchesLanguage = !this.filters.language || cardLanguage === this.filters.language
      const matchesCondition = !this.filters.condition || cardCondition === this.filters.condition
      const matchesFoil = !this.filters.foilOnly || isFoil

      if (matchesSearch && matchesLanguage && matchesCondition && matchesFoil) {
        card.classList.remove('hidden')
        // Animation d'apparition
        card.classList.add('animate-fade-in')
      } else {
        card.classList.add('hidden')
        card.classList.remove('animate-fade-in')
      }
    })
  }
}
