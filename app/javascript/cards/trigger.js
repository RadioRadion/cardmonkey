const displayImage = () => {
  const cards = document.querySelectorAll(".card-product");
  cards.forEach((card) => {
    card.addEventListener('mouseover', (e) => {
      const element = document.querySelectorAll(`[data-img-id='${e.currentTarget.dataset.id}']`)[0];
      element.style.display = "block";
    })
  })
  cards.forEach((card) => {
    card.addEventListener('mouseout', (e) => {
      const element = document.querySelectorAll(`[data-img-id='${e.currentTarget.dataset.id}']`)[0];
      element.style.display = "none";
    })
  })
}

export { displayImage };
