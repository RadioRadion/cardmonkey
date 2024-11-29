// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "@rails/actioncable"

// Initialize Stimulus
import "./controllers"

// Initialize ActiveStorage
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

// Initialize channels
import "./channels"
