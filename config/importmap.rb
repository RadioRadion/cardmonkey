# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/actioncable", to: "actioncable.esm.js", preload: true

# Pin all controllers
pin_all_from "app/javascript/controllers", under: "controllers", preload: true

# ActionCable setup
pin "channels", to: "channels/index.js", preload: true
pin "channels/consumer", to: "channels/consumer.js", preload: true
pin "channels/chatroom_channel", to: "channels/chatroom_channel.js", preload: true

# Pin all JavaScript files
pin_all_from "app/javascript", under: "javascript", preload: true
