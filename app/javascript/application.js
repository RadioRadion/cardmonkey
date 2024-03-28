// app/javascript/application.js
import { Application } from "@hotwired/stimulus"

// Importez chaque contrôleur spécifiquement
import HelloController from "./controllers/hello_controller"
import AutoCompleteController from "./controllers/autocomplete_controller"

// Démarrage de l'application Stimulus
window.Stimulus = Application.start()

// Enregistrement des contrôleurs
Stimulus.register("hello", HelloController)
Stimulus.register("autocomplete", AutoCompleteController)
