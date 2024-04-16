# Pin npm packages by running ./bin/importmap

# config/importmap.rb
pin "application", to: "application.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3
pin "flowbite", to: "https://cdn.jsdelivr.net/npm/flowbite@latest/dist/flowbite.min.js"

