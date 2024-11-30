// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "@rails/actioncable"

// Import controllers
import "./controllers"

// Import channels
import "channels"

// Ensure Turbo is properly configured
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = true
