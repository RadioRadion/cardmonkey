import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions", "cardId", "extension"]

  search(event) {
    const query = this.inputTarget.value;
    if (query.length < 3) {
      this.suggestionsTarget.innerHTML = '';
      return;
    }

    fetch(`/cards/search?query=${query}`)
      .then(response => response.json())
      .then(data => this.displaySuggestions(data))
      .catch(error => console.log(error));
  }

  displaySuggestions(data) {
    this.suggestionsTarget.innerHTML = '';
    data.forEach((item) => {
      const suggestionElement = document.createElement('div');
      
      // Création et ajout du nom en français et en anglais
      const nameElement = document.createElement('div');
      nameElement.textContent = `${item.name_fr} / ${item.name_en}`;
      suggestionElement.appendChild(nameElement);
  
      // Assurez-vous d'assigner correctement nameFr et nameEn au dataset
      suggestionElement.dataset.oracleId = item.oracle_id;
      suggestionElement.dataset.nameFr = item.name_fr; // Ajoutez cette ligne
      suggestionElement.dataset.nameEn = item.name_en; // Ajoutez cette ligne
      suggestionElement.dataset.action = 'click->autocomplete#select';
      this.suggestionsTarget.appendChild(suggestionElement);
    });
  }
  

  select(event) {
    const oracleId = event.currentTarget.dataset.oracleId;
    const nameFr = event.currentTarget.dataset.nameFr;
    const nameEn = event.currentTarget.dataset.nameEn;
  
    // Nettoyage du champ des suggestions
    this.suggestionsTarget.innerHTML = '';
  
    // Remplir le champ de texte (inputTarget) avec le nom de la carte
    // en français si disponible, sinon en anglais.
    this.inputTarget.value = nameFr || nameEn; // Utilisation de nameFr si disponible, sinon nameEn
  
    // Requête au serveur pour obtenir les versions de la carte
    fetch(`/cards/versions?oracle_id=${oracleId}`)
      .then(response => response.json())
      .then(versions => this.fillExtensions(versions))
      .catch(error => console.log(error));
  }    

  fillExtensions(versions) {
    const select = this.extensionTarget;
    select.innerHTML = ''; // Nettoyage des options existantes
  
    versions.forEach(version => {
      const option = document.createElement('option');
      option.value = version.scryfall_id; // Utilisez scryfall_id ou un identifiant unique pour cette version
      option.text = `${version.extension}`;
      select.appendChild(option);
    });
  }
  
}