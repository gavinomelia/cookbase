// Tab switching
document.addEventListener("turbo:load", function () {
  // Declare switchTab in the global scope
  window.switchTab = function(tab) {
    const tabs = document.querySelectorAll('.tab-content');
    const buttons = document.querySelectorAll('.tab-btn');

    tabs.forEach(t => {
      t.classList.remove('active');
    });

    buttons.forEach(btn => {
      btn.classList.remove('active');
    });

    document.getElementById(tab).classList.add('active');

    buttons.forEach(btn => {
      if (btn.textContent.trim().toLowerCase() === tab) {
        btn.classList.add('active');
      }
    });
  };
});

// Scale factor update
function updateScale(scaleFactor) {
  const recipeContent = document.querySelector('.recipe-content');
  if (recipeContent) {
    recipeContent.style.transform = `scale(${scaleFactor})`;
  }
}

