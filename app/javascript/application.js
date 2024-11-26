// app/javascript/application.js
import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import { createConsumer } from "@rails/actioncable"

// Importez chaque contrôleur spécifiquement
import HelloController from "./controllers/hello_controller"
import AutoCompleteController from "./controllers/autocomplete_controller"
import UserCardController from "./controllers/user_card_controller"
import UserWantedCardController from "./controllers/user_wanted_card_controller"
import ModalController from "./controllers/modal_controller"
import DropdownController from "./controllers/dropdown_controller"
import MobileMenuController from "./controllers/mobile_menu_controller"
import TradeController from "./controllers/trade_controller"
import AvatarUploadController from "./controllers/avatar_upload_controller"
import TradeSelectionController from "./controllers/trade_selection_controller"
import CardQuantityController from "./controllers/card_quantity_controller"
import TradeSummaryController from "./controllers/trade_summary_controller"
import CardPreviewController from "./controllers/card_preview_controller"
import FiltersController from "./controllers/filters_controller"

// Start ActiveStorage
ActiveStorage.start()

// Create ActionCable consumer
window.App = window.App || {}
window.App.cable = createConsumer()

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
Stimulus.register("avatar-upload", AvatarUploadController)
Stimulus.register("trade-selection", TradeSelectionController)
Stimulus.register("card-quantity", CardQuantityController)
Stimulus.register("trade-summary", TradeSummaryController)
Stimulus.register("card-preview", CardPreviewController)
Stimulus.register("filters", FiltersController)
