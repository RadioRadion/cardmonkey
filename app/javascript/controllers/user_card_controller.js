import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"
Rails.start()

export default class extends Controller {
  static targets = ["quantity"]
  static values = {
    url: String,
    userId: Number,
    userCardId: Number
  }

  decrement() {
    let currentValue = Number(this.quantityTarget.value);
    if (currentValue > 1) {
      this.quantityTarget.value = currentValue - 1;
      this.updateServer(currentValue - 1);
    }
  }

  increment() {
    let currentValue = Number(this.quantityTarget.value);
    this.quantityTarget.value = currentValue + 1;
    this.updateServer(currentValue + 1);
  }

  updateServer(newQuantity) {
    console.log("userIdValue:", this.userIdValue, "userCardIdValue:", this.userCardIdValue);

    const url = `/users/${this.userIdValue}/user_cards/${this.userCardIdValue}`;
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

    fetch(url, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        user_card: { quantity: newQuantity }
      }),
      credentials: 'include'
    }).then(response => {
      if (response.ok) {
        response.json().then(data => {
          console.log("Quantité mise à jour avec succès.", data.message);
          // Mettez à jour l'UI ici si nécessaire, par exemple :
          // this.quantityTarget.value = data.quantity;
        });
      } else {
        console.error("Erreur lors de la mise à jour");
        response.json().then(data => {
          console.error(data.errors);
          // Affichez les erreurs ici si nécessaire
        });
      }
    })
  }
  

  delete(e) {
    e.preventDefault();

    if (!confirm("Êtes-vous sûr de vouloir supprimer cet élément ?")) {
      return;
    }

    const userCardId = this.element.dataset.userCardId;
    const userId = this.element.dataset.userId; // Récupérer l'ID de l'utilisateur
    console.log(userCardId);
    console.log(userId);

    // Obtention du jeton CSRF à partir de la balise meta
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    
    fetch(`/users/${userId}/user_cards/${userCardId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      credentials: 'include'
    }).then(response => {
      if (response.ok) {
        this.element.remove();
        console.log(this.element);
      } else {
        console.error('Erreur lors de la suppression');
        console.log(this.element);
      }
    }).catch(error => console.error('Erreur:', error));
  }
}
