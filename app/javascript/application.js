// Instant Search Functionality
document.addEventListener("turbo:load", function() {
  const searchInput = document.querySelector(".search-input");
  const tagSelect = document.getElementById('tag-select');
  const newTagInput = document.getElementById('new-tag-input');
  const addTagButton = document.getElementById('add-tag-button');

  if (tagSelect) {
    // Event listener for tag selection changes
    tagSelect.addEventListener('change', function() {
      this.form.requestSubmit(); // Submits the form via Turbo
    });
  }

  if (searchInput) {
    searchInput.addEventListener("input", function() {
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        this.form.requestSubmit(); // Submits the form via Turbo
      }, 300); // Debounce the search input to avoid excessive requests
    });
  }

  if (addTagButton) {
    addTagButton.addEventListener('click', function() {
      const newTag = newTagInput.value.trim();
      if (newTag) {
        // Create a new tag item and add it to the current tags list
        const currentTagsList = document.querySelector('ul'); // Select the <ul> where current tags are listed
        const newTagItem = document.createElement('li');
        newTagItem.textContent = newTag;
        currentTagsList.appendChild(newTagItem);

        // Optionally, you can update the recipe's tag_list parameter to include the new tag
        // You might need to adjust this part to fit your form submission logic

        newTagInput.value = ''; // Clear the input field
      } else {
        alert('Please enter a tag.'); // Alert if the input is empty
      }
    });
  }

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

// Function to remove fields
function removeFields(event) {
  event.preventDefault();
  let field = event.target.closest('.ingredient-fields');
  if (field) {
    field.querySelector('input[name*="_destroy"]').value = '1';
    field.style.display = 'none';
  }
}

// Function to add fields
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

