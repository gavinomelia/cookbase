document.addEventListener("turbo:load", function () {
  // Add event listeners for add/remove buttons
  const addIngredientButton = document.querySelector("#add_ingredient");
  const ingredientsContainer = document.querySelector("#ingredients");

  // Event listener for adding new ingredient fields
  if (addIngredientButton) {
    addIngredientButton.addEventListener("click", function (event) {
      event.preventDefault();
      addFields();
    });
  }

  // Event listener for removing ingredient fields
  if (ingredientsContainer) {
    ingredientsContainer.addEventListener("click", function (event) {
      if (event.target.matches(".remove_ingredient")) {
        event.preventDefault();
        removeFields(event);
      }
    });
  }
});

// Function to remove fields
function removeFields(event) {
  const field = event.target.closest(".ingredient-fields");
  if (field) {
    const destroyField = field.querySelector('input[name*="_destroy"]');
    if (destroyField) {
      destroyField.value = "1"; // Mark the field for destruction
    }
    field.style.display = "none"; // Hide the field visually
  }
}

// Function to add fields
function addFields() {
  const time = new Date().getTime(); // Unique timestamp for new fields
  const template = document.querySelector("#ingredient_template")?.innerHTML;

  if (template) {
    // Replace "NEW_RECORD" with unique time-based ID
    const newFields = template.replace(/NEW_RECORD/g, time);

    // Insert the new ingredient fields into the container
    const ingredientsContainer = document.querySelector("#ingredients");
    if (ingredientsContainer) {
      ingredientsContainer.insertAdjacentHTML("beforeend", newFields);
    } else {
      console.error("Ingredients container not found.");
    }
  } else {
    console.error("Ingredient template not found.");
  }
}

