import { Controller } from "@hotwired/stimulus"

// Toggles between the "paste a list" and "CSV file" import panels and keeps the
// hidden `source` field in sync.
export default class extends Controller {
  static targets = ["source", "panel", "tab"]

  connect() {
    this.select({ params: { source: this.sourceTarget.value || "decklist" } })
  }

  select(event) {
    const source = event.params ? event.params.source : event.currentTarget.dataset.source
    this.sourceTarget.value = source

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.source !== source)
    })

    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.source === source
      tab.classList.toggle("bg-white", active)
      tab.classList.toggle("text-gray-900", active)
      tab.classList.toggle("shadow", active)
      tab.classList.toggle("text-gray-500", !active)
    })
  }
}
