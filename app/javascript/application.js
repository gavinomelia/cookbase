//Instant Search Functionality
document.addEventListener("turbo:load", function() {
  const searchInput = document.querySelector(".search-input");

  if (searchInput) {
    searchInput.addEventListener("input", function() {
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        this.form.requestSubmit(); // Submits the form via Turbo
      }, 300); // Debounce the search input to avoid excessive requests
    });
  }
});

document.addEventListener('DOMContentLoaded', function() {
  // Event delegation for dynamically added elements
  document.addEventListener('click', function(event) {
    if (event.target.matches('.remove_ingredient')) {
      event.preventDefault();
      removeFields(event);
    } else if (event.target.matches('#add_ingredient')) {
      event.preventDefault();
      addFields(event);
    }
  });
});

function removeFields(event) {
  event.preventDefault();
  let field = event.target.closest('.ingredient-fields');
  if (field) {
    field.querySelector('input[name*="_destroy"]').value = '1';
    field.style.display = 'none';
  }
}

function addFields(event) {
  event.preventDefault();
  let time = new Date().getTime();
  let template = document.querySelector('#ingredient_template').innerHTML;
  template = template.replace(/NEW_RECORD/g, time);
  document.querySelector('#ingredients').insertAdjacentHTML('beforeend', template);

  // Add event listener to the new remove link
  let newField = document.querySelector('#ingredients').lastElementChild;
  newField.querySelector('.remove_ingredient').addEventListener('click', removeFields);
}


