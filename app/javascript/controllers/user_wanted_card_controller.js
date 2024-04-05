import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  delete(e) {
    e.preventDefault();

    if (!confirm("Êtes-vous sûr de vouloir supprimer cet élément ?")) {
      return;
    }

    const userWantedCardId = this.element.dataset.userWantedCardId;
    const userId = this.element.dataset.userId; // Récupérer l'ID de l'utilisateur
    console.log(userWantedCardId)
    console.log(userId)

    // Obtention du jeton CSRF à partir de la balise meta
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    
    fetch(`/users/${userId}/user_wanted_cards/${userWantedCardId}`, {
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
