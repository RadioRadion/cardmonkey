// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "./controllers"
import * as ActiveStorage from "@rails/activestorage"
import { createConsumer } from "@rails/actioncable"

// Initialize ActionCable
window.App = window.App || {}
window.App.cable = createConsumer()

// Initialize ActiveStorage
ActiveStorage.start()
import "controllers"
