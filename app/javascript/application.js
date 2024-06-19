import 'bootstrap';
import { Turbo } from "@hotwired/turbo-rails"

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

    let newField = document.querySelector('#ingredients').lastElementChild;
    newField.querySelector('.remove_ingredient').addEventListener('click', removeFields);
    console.log("New field added");
  }

  document.querySelector('#ingredients').addEventListener('click', function(event) {
    if (event.target.classList.contains('remove_ingredient')) {
      removeFields(event);
    }
  });

  document.querySelectorAll('.remove_ingredient').forEach(link => {
    link.addEventListener('click', removeFields);
  });

  document.querySelector('#add_ingredient').addEventListener('click', addFields);
});

