const triggerForm = () => {

  //fonction trouvée sur le net pour pouvoir applique une méthode remove toute prête sur l'array plus loin
  Array.prototype.remove = function() {
    var what, a = arguments, L = a.length, ax;
    while (L && this.length) {
        what = a[--L];
        while ((ax = this.indexOf(what)) !== -1) {
            this.splice(ax, 1);
        }
    }
    return this;
  };

  const one = document.querySelector("#one");
  const two = document.querySelector("#two");

  const monTotalDiv = document.querySelector("#monTotal");
  const sonTotalDiv = document.querySelector("#sonTotal");
  const monTotal = []
  const sonTotal = []
  //préparer le reducer pour faire la somme plus loin
  const reducer = (accumulator, currentValue) => accumulator + currentValue;
  //pour chopper tous les éléments du form
  var loginForm = document.forms.sneackyValue;
  // loginForm.elements.offer.placeholder = 'test@example.com';
  // loginForm.elements.target.placeholder = 'password';

  // je récupère toutes les cartes de la collect current puis collect target
  const cardsOffer = document.querySelectorAll(".card-offer");
  const offer = [];
  const cardsTarget = document.querySelectorAll(".card-target");
  const target = [];


  cardsTarget.forEach(card => card.addEventListener("click", (event) => {
    if (card.classList.contains("selected")) {
      //Si c'est la dernière carte sélectionnée
      if (sonTotal.length == "1" ) {
        sonTotalDiv.textContent = 0;
        sonTotal.shift();
      }
      else {
        sonTotal.remove(parseFloat(card.dataset.price));
        sonTotalDiv.textContent = Math.round(sonTotal.reduce(reducer)*100)/100;
      }
    }
    else {
      sonTotal.push(parseFloat(card.dataset.price));
      sonTotalDiv.textContent = Math.round(sonTotal.reduce(reducer)*100)/100;
    }
    if (card.classList.length === 2) {
      card.classList.add("selected");
      target.push(card.dataset.id);
      loginForm.elements.target.value = target.toString();
      // two.value = target.toString();
    }
    else {
      target.remove(card.dataset.id);
      card.classList.remove("selected");
      loginForm.elements.target.value = target.toString();
      // two.value = target.toString();
    }
  }));

  cardsOffer.forEach(card => card.addEventListener("click", (event) => {
    if (card.classList.contains("selected")) {
      if (monTotal.length == "1" ) {
        monTotalDiv.textContent = 0;
        monTotal.shift();
      }
      else {
        monTotal.remove(parseFloat(card.dataset.price));
        monTotalDiv.textContent = Math.round(monTotal.reduce(reducer)*100)/100;
      }
    }
    else {
      monTotal.push(parseFloat(card.dataset.price));
      monTotalDiv.textContent = Math.round(monTotal.reduce(reducer)*100)/100;
    }
    if (card.classList.length === 2) {
      //la classe selected permet de rendre la card verte sur le clic
      card.classList.add("selected");
      //on récupère l'id de la carte cliquée pour l'insérer dans la valeur finale
      offer.push(card.dataset.id);
      //on actualise la value du form de l'input Offer
      // one.value = offer.toString();
      loginForm.elements.offer.value = offer.toString();
    }
    else {
      offer.remove(card.dataset.id);
      card.classList.remove("selected");
      // one.value = offer.toString();
      loginForm.elements.offer.value = offer.toString();
    }

  }));
}

export { triggerForm };
