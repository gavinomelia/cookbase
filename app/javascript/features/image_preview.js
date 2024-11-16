export function previewImage(event) {
  const input = event.target;

  if (!input.files || input.files.length === 0) {
    console.error("No file selected");
    return;
  }

  const file = input.files[0];

  const reader = new FileReader();

  reader.onload = function(e) {
    const img = document.getElementById("uploaded-image-preview");
      if (img) {
      img.src = e.target.result;
      img.classList.remove("opacity-60");
      img.classList.add("opacity-100");
    } else {
      console.error("Image element not found");
    }
  };

  reader.readAsDataURL(file);
}

window.previewImage = previewImage;
