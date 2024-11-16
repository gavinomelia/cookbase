document.addEventListener("turbo:load", function () {
  const newTagInput = document.getElementById("new-tag-input");
  const addTagButton = document.getElementById("add-tag-button");

  if (addTagButton) {
    addTagButton.addEventListener("click", function () {
      const newTag = newTagInput.value.trim();
      if (newTag) {
        // Create a new tag item and add it to the current tags list
        const currentTagsList = document.querySelector("ul"); // Select the <ul> where current tags are listed
        const newTagItem = document.createElement("li");
        newTagItem.textContent = newTag;
        currentTagsList.appendChild(newTagItem);

        newTagInput.value = ""; // Clear the input field
      } else {
        alert("Please enter a tag."); // Alert if the input is empty
      }
    });
  }
});

