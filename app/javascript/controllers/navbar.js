document.addEventListener('turbo:load', function() {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;

  // Initialize scroll state
  const updateNavbar = () => {
    navbar.classList.toggle('scrolled', window.scrollY > 50);
  };

  // Set initial state
  updateNavbar();

  // Add scroll listener (with throttling)
  let isScrolling;
  window.addEventListener('scroll', () => {
    window.clearTimeout(isScrolling);
    isScrolling = setTimeout(() => {
      updateNavbar();
    }, 50); // Runs every 50ms while scrolling
  }, { passive: true });
});
