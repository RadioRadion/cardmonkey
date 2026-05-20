import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["listBtn", "gridBtn", "listView", "gridView"]
  static values = { storageKey: { type: String, default: "viewPreference" } }

  connect() {
    const savedView = localStorage.getItem(this.storageKeyValue) || "list"
    this.setView(savedView)
  }

  showList() {
    this.setView("list")
    localStorage.setItem(this.storageKeyValue, "list")
  }

  showGrid() {
    this.setView("grid")
    localStorage.setItem(this.storageKeyValue, "grid")
  }

  setView(view) {
    if (view === "list") {
      this.listBtnTarget.classList.add("active")
      this.gridBtnTarget.classList.remove("active")
      if (this.hasListViewTarget) this.listViewTarget.classList.remove("hidden")
      if (this.hasGridViewTarget) this.gridViewTarget.classList.add("hidden")
    } else {
      this.listBtnTarget.classList.remove("active")
      this.gridBtnTarget.classList.add("active")
      if (this.hasListViewTarget) this.listViewTarget.classList.add("hidden")
      if (this.hasGridViewTarget) this.gridViewTarget.classList.remove("hidden")
    }
  }
}
