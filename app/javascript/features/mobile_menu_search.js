document.addEventListener("turbo:load", function () {
  const menuToggle = document.getElementById("menu-toggle");
  const mobileMenu = document.getElementById("mobile-menu");
  const mobileSearchToggle = document.getElementById("mobile-search-toggle");
  const mobileSearchOverlay = document.getElementById("mobile-search-overlay");
  const mobileSearchClose = document.getElementById("mobile-search-close");

  if (menuToggle && mobileMenu && !menuToggle.dataset.listener) {
    menuToggle.addEventListener("click", () => {
      mobileMenu.classList.toggle("hidden");
    });
    menuToggle.dataset.listener = "true"; // Mark listener as added
  }

  if (mobileSearchToggle && mobileSearchOverlay && !mobileSearchToggle.dataset.listener) {
    mobileSearchToggle.addEventListener("click", () => {
      mobileSearchOverlay.classList.remove("hidden");
    });
    mobileSearchToggle.dataset.listener = "true"; // Mark listener as added
  }

  if (mobileSearchClose && mobileSearchOverlay && !mobileSearchClose.dataset.listener) {
    mobileSearchClose.addEventListener("click", () => {
      mobileSearchOverlay.classList.add("hidden");
    });
    mobileSearchClose.dataset.listener = "true"; // Mark listener as added
  }

  if (mobileSearchOverlay && !mobileSearchOverlay.dataset.listener) {
    mobileSearchOverlay.addEventListener("click", (event) => {
      if (event.target === mobileSearchOverlay) {
        mobileSearchOverlay.classList.add("hidden");
      }
    });
    mobileSearchOverlay.dataset.listener = "true"; // Mark listener as added
  }
});

