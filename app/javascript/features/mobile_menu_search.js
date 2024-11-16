document.addEventListener("turbo:load", function() {
  const menuToggle = document.getElementById('menu-toggle');
  const mobileMenu = document.getElementById('mobile-menu');
  const mobileSearchToggle = document.getElementById('mobile-search-toggle');
  const mobileSearchOverlay = document.getElementById('mobile-search-overlay');
  const mobileSearchClose = document.getElementById('mobile-search-close');
  let menuInitialized = false; // Flag to avoid re-initializing

  // Initialize mobile menu functionality
  if (!menuInitialized && menuToggle && mobileMenu) {
    menuToggle.addEventListener('click', () => {
      mobileMenu.classList.toggle('hidden');
    });
    menuInitialized = true; // Set the flag to true
  }

  // Initialize mobile search functionality
  if (mobileSearchToggle) {
    mobileSearchToggle.onclick = function() {
      mobileSearchOverlay.classList.toggle('hidden');
    };
  }

  if (mobileSearchClose) {
    mobileSearchClose.onclick = function() {
      mobileSearchOverlay.classList.add('hidden');
    };
  }

  if (mobileSearchOverlay) {
    mobileSearchOverlay.onclick = function(event) {
      if (event.target === this) {
        this.classList.add('hidden');
      }
    };
  }
});

