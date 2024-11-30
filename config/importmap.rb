# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"

# Pin all controllers
pin_all_from "app/javascript/controllers", under: "controllers"

# ActionCable setup
pin "channels", to: "channels/index.js", preload: true
pin "channels/consumer", to: "channels/consumer.js", preload: true
pin "channels/chatroom_channel", to: "channels/chatroom_channel.js", preload: true

# Pin all JavaScript files
pin_all_from "app/javascript", under: "javascript", preload: true
