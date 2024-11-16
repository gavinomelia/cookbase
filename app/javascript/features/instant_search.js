document.addEventListener("turbo:load", function () {
  const searchInput = document.querySelector(".search-input");
  const tagSelect = document.getElementById("tag-select");

  // Handle tag selection changes
  if (tagSelect) {
    tagSelect.addEventListener("change", function () {
      if (this.form) {
        this.form.requestSubmit(); // Submits the form via Turbo
      } else {
        console.error("Form not found for tag select.");
      }
    });
  }

  // Handle instant search
  if (searchInput) {
    searchInput.addEventListener("input", function () {
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        if (this.form) {
          this.form.requestSubmit(); // Submits the form via Turbo
        } else {
          console.error("Form not found for search input.");
        }
      }, 300); // Debounce the search input
    });
  }
});

