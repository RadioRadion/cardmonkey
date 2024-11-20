// app/javascript/application.js
import { Application } from "@hotwired/stimulus"

// Importez chaque contrôleur spécifiquement
import HelloController from "./controllers/hello_controller"
import AutoCompleteController from "./controllers/autocomplete_controller"
import UserCardController from "./controllers/user_card_controller"
import UserWantedCardController from "./controllers/user_wanted_card_controller"
import ModalController from "./controllers/modal_controller"
import DropdownController from "./controllers/dropdown_controller"
import MobileMenuController from "./controllers/mobile_menu_controller"
import TradeController from "./controllers/trade_controller"

// Démarrage de l'application Stimulus
window.Stimulus = Application.start()

// Enregistrement des contrôleurs
Stimulus.register("hello", HelloController)
Stimulus.register("autocomplete", AutoCompleteController)
Stimulus.register("user-card", UserCardController)
Stimulus.register("user-wanted-card", UserWantedCardController)
Stimulus.register("modal", ModalController)
Stimulus.register("dropdown", DropdownController)
Stimulus.register("mobile-menu", MobileMenuController)
Stimulus.register("trade", TradeController)