// Proof of Travel — small site-wide JS helpers.
// 1. Logo image fallback (in case the hosted PNG fails to load)
// 2. Mobile hamburger menu toggle

(function () {
  // ─── Logo fallback ───
  var img = document.getElementById('nav-logo-img');
  var txt = document.getElementById('nav-logo-text');
  if (img && txt) {
    img.onerror = function () { this.style.display = 'none'; txt.style.display = 'block'; };
    img.onload  = function () { txt.style.display = 'none'; };
    if (img.complete && img.naturalWidth === 0) {
      img.style.display = 'none';
      txt.style.display = 'block';
    }
  }
})();

(function () {
  // ─── Hamburger toggle ───
  var toggle = document.querySelector('.n-toggle');
  var links  = document.getElementById('n-links');
  if (!toggle || !links) return;

  function setOpen(open) {
    toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    links.classList.toggle('is-open', open);
  }

  toggle.addEventListener('click', function () {
    var isOpen = toggle.getAttribute('aria-expanded') === 'true';
    setOpen(!isOpen);
  });

  // Close on link tap (so navigating via the drawer doesn't leave it open).
  links.querySelectorAll('a').forEach(function (a) {
    a.addEventListener('click', function () { setOpen(false); });
  });

  // Esc key closes the drawer.
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') {
      setOpen(false);
      toggle.focus();
    }
  });

  // Close if viewport grows past mobile breakpoint (e.g., user rotates tablet).
  var mq = window.matchMedia('(min-width: 769px)');
  if (mq.addEventListener) {
    mq.addEventListener('change', function (e) { if (e.matches) setOpen(false); });
  }
})();
