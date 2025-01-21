# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/actioncable", to: "actioncable.esm.js", preload: true
pin "@rails/activestorage", to: "activestorage.esm.js", preload: true

# ActionCable setup
pin "channels", to: "channels/index.js", preload: true
pin "channels/consumer", to: "channels/consumer.js", preload: true
pin "channels/chatroom_channel", to: "channels/chatroom_channel.js", preload: true
pin "channels/scroll", to: "channels/scroll.js", preload: true

# Application JavaScript
pin "cards/trigger", to: "cards/trigger.js", preload: true
pin "forms/trigger_form", to: "forms/trigger_form.js", preload: true

# Controllers (pin last to ensure dependencies are loaded first)
pin_all_from "app/javascript/controllers", under: "controllers", preload: true
