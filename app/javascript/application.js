// app/javascript/application.js
import { Application } from "@hotwired/stimulus"

// Importez chaque contrôleur spécifiquement
import HelloController from "./controllers/hello_controller"
import AutoCompleteController from "./controllers/autocomplete_controller"
import UserCardController from "./controllers/user_card_controller"

// Démarrage de l'application Stimulus
window.Stimulus = Application.start()

// Enregistrement des contrôleurs
Stimulus.register("hello", HelloController)
Stimulus.register("autocomplete", AutoCompleteController)
Stimulus.register("user-card", UserCardController) 
