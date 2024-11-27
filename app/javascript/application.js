// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"

// Initialize Turbo
addEventListener("turbo:before-cache", () => {
  // Any cleanup needed before caching
})

// Initialize Stimulus
import "./controllers"

// Initialize ActiveStorage
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

// Initialize ActionCable
import { createConsumer } from "@rails/actioncable"
window.App = window.App || {}
window.App.cable = createConsumer()
