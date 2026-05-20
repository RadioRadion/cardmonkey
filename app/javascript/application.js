// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "@rails/actioncable"
import "@rails/activestorage"

// Import controllers
import "controllers"

// Import channels
import "channels"

// Initialize ActiveStorage
import { DirectUpload } from "@rails/activestorage"
window.DirectUpload = DirectUpload

// Ensure Turbo is properly configured
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = true

// Configure Turbo Stream actions
document.addEventListener("turbo:load", () => {
  // Ensure forms don't trigger full page loads
  document.querySelectorAll("form[data-remote='true']").forEach(form => {
    form.setAttribute("data-turbo", "true")
  })
})
