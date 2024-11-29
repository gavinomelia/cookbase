document.addEventListener("turbo:load", function () {
  const scaleRange = document.querySelector("#scale_range");

  if (scaleRange) {
    scaleRange.addEventListener("input", function () {
      const scaleFactor = this.value;
      const recipeId = this.dataset.recipeId;

      if (scaleFactor && recipeId) {
        fetch(`/recipes/${recipeId}/scale?scale_factor=${scaleFactor}`, {
          headers: { Accept: "text/vnd.turbo-stream.html" },
        })
          .then((response) => response.text())
          .then((html) => Turbo.renderStreamMessage(html))
          .catch((error) => console.error("Error updating scale factor:", error));
      } else {
        console.error("Missing scaleFactor or recipeId");
      }
    });
  }
});

