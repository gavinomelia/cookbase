document.addEventListener("turbo:load", function () {
  const searchInputs = document.querySelectorAll(".search-input"); // Handle both mobile and desktop inputs
  const tagSelects = document.querySelectorAll(".tag-select"); // Handle tag selection for both views

  // Handle Tag Selection
  tagSelects.forEach((tagSelect) => {
    if (tagSelect) {
      tagSelect.addEventListener("change", function () {
        if (this.form) {
          this.form.requestSubmit(); // Submits the form via Turbo
        } else {
          console.error("Form not found for tag select.");
        }
      });
    }
  });

  // Handle Instant Search Input
  searchInputs.forEach((searchInput) => {
    if (searchInput) {
      searchInput.addEventListener("input", function () {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
          if (this.form) {
            this.form.requestSubmit(); // Submits the form via Turbo
          } else {
            console.error("Form not found for search input.");
          }
        }, 300); // Debounce to avoid rapid requests
      });
    }
  });
});

