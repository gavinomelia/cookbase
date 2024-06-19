// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// Import Turbo and start it
import { Turbo } from "@hotwired/turbo-rails"
Turbo.start()

document.addEventListener("turbo:load", function() {
  console.log("Turbo loaded");

  function removeFields(event) {
    event.preventDefault();
    let field = event.target.closest('.ingredient-fields');
    field.querySelector('input[name*="_destroy"]').value = '1';
    field.style.display = 'none';
    console.log("Field removed");
  }

  function addFields(event) {
    event.preventDefault();
    console.log("Add ingredient clicked");
    let time = new Date().getTime();
    let template = document.querySelector('#ingredient_template').innerHTML;
    template = template.replace(/NEW_RECORD/g, time);
    document.querySelector('#ingredients').insertAdjacentHTML('beforeend', template);

    // Add event listener to the new remove link
    let newField = document.querySelector('#ingredients').lastElementChild;
    newField.querySelector('.remove_ingredient').addEventListener('click', removeFields);
    console.log("New field added");
  }

  document.querySelectorAll('.remove_ingredient').forEach(link => {
    link.addEventListener('click', removeFields);
  });

  document.querySelector('#add_ingredient').addEventListener('click', addFields);
});

