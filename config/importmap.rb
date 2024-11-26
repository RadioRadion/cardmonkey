# Pin npm packages by running ./bin/importmap

# config/importmap.rb
pin "application", to: "application.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@7.1.2/app/assets/javascripts/activestorage.esm.js"
pin "@rails/actioncable", to: "https://ga.jspm.io/npm:@rails/actioncable@7.1.2/app/assets/javascripts/actioncable.esm.js"
pin "tom-select" # @2.3.1
pin "./channels", to: "channels/index.js"
