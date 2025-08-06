document.addEventListener('DOMContentLoaded', function() {
  const scrollContainer = document.querySelector('.scroll-trips-container');
  const scrollLeftBtn = document.querySelector('.scroll-left');
  const scrollRightBtn = document.querySelector('.scroll-right');

  if (scrollContainer && scrollLeftBtn && scrollRightBtn) {
    // Scroll left button functionality
    scrollLeftBtn.addEventListener('click', function() {
      scrollContainer.scrollBy({
        left: -300, // Adjust this value to control scroll amount
        behavior: 'smooth'
      });
    });

    // Scroll right button functionality
    scrollRightBtn.addEventListener('click', function() {
      scrollContainer.scrollBy({
        left: 300, // Adjust this value to control scroll amount
        behavior: 'smooth'
      });
    });

    // Show/hide buttons based on scroll position
    scrollContainer.addEventListener('scroll', function() {
      scrollLeftBtn.style.display = scrollContainer.scrollLeft > 0 ? 'flex' : 'none';
      scrollRightBtn.style.display = scrollContainer.scrollLeft < (scrollContainer.scrollWidth - scrollContainer.clientWidth) ? 'flex' : 'none';
    });

    // Initial check
    scrollLeftBtn.style.display = 'none';
    if (scrollContainer.scrollWidth <= scrollContainer.clientWidth) {
      scrollRightBtn.style.display = 'none';
    }
  }
});
