document.addEventListener("DOMContentLoaded", function () {
  const menuToggle = document.getElementById("menu-toggle");
  const mobileMenu = document.getElementById("mobile-menu");
  const mobileSearchToggle = document.getElementById("mobile-search-toggle");
  const mobileSearchOverlay = document.getElementById("mobile-search-overlay");
  const mobileSearchClose = document.getElementById("mobile-search-close");

  // Mobile Menu Toggle
  if (menuToggle && mobileMenu) {
    menuToggle.addEventListener("click", () => {
      mobileMenu.classList.toggle("hidden");
    });
  }

  // Mobile Search Overlay Toggle
  if (mobileSearchToggle && mobileSearchOverlay) {
    mobileSearchToggle.onclick = () => {
      mobileSearchOverlay.classList.toggle("hidden");
    };
  }

  // Close Mobile Search Overlay
  if (mobileSearchClose && mobileSearchOverlay) {
    mobileSearchClose.onclick = () => {
      mobileSearchOverlay.classList.add("hidden");
    };

    mobileSearchOverlay.onclick = (event) => {
      if (event.target === mobileSearchOverlay) {
        mobileSearchOverlay.classList.add("hidden");
      }
    };
  }
});

