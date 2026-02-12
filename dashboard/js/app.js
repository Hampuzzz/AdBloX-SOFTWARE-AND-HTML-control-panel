// AdBloX MESH — Main app logic (sidebar, navigation)

document.addEventListener('DOMContentLoaded', async () => {
  // Highlight active nav link
  const currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.sidebar__link').forEach(link => {
    const href = link.getAttribute('href');
    if (href === currentPage || (currentPage === '' && href === 'index.html')) {
      link.classList.add('sidebar__link--active');
    }
  });

  // Mobile sidebar toggle
  const toggle = document.querySelector('.mobile-toggle');
  const sidebar = document.querySelector('.sidebar');
  const overlay = document.querySelector('.sidebar-overlay');

  if (toggle) {
    toggle.addEventListener('click', () => {
      sidebar.classList.toggle('sidebar--open');
      overlay.classList.toggle('sidebar-overlay--visible');
    });
  }

  if (overlay) {
    overlay.addEventListener('click', () => {
      sidebar.classList.remove('sidebar--open');
      overlay.classList.remove('sidebar-overlay--visible');
    });
  }

  // Init API
  await API.init();

  // Call page-specific init
  if (typeof pageInit === 'function') {
    pageInit();
  }
});
