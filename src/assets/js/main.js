// Proof of Travel — small site-wide JS helpers.
// Currently handles the nav logo image fallback.
(function () {
  var img = document.getElementById('nav-logo-img');
  var txt = document.getElementById('nav-logo-text');
  if (!img || !txt) return;

  img.onerror = function () {
    this.style.display = 'none';
    txt.style.display = 'block';
  };
  img.onload = function () {
    txt.style.display = 'none';
  };
  if (img.complete && img.naturalWidth === 0) {
    img.style.display = 'none';
    txt.style.display = 'block';
  }
})();
