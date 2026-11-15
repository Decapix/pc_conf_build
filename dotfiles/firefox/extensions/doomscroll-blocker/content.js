(() => {
  const LIMIT_SECONDS = 60;
  let elapsed = 0;
  let lastUrl = location.href;
  let overlay = null;

  function pauseAllVideos() {
    document.querySelectorAll('video').forEach((v) => {
      try {
        v.pause();
      } catch (e) {
        // ignore
      }
    });
  }

  function sendSystemNotification() {
    try {
      if (typeof chrome !== 'undefined' && chrome.runtime && chrome.runtime.id) {
        chrome.runtime.sendMessage({ type: 'doomscroll-alert', url: location.href });
      }
    } catch (e) {
      // ignore
    }
  }

  function showOverlay() {
    if (overlay) {
      overlay.remove();
    }
    overlay = document.createElement('div');
    overlay.id = 'doomscroll-overlay';

    const card = document.createElement('div');
    card.className = 'doomscroll-card';

    const title = document.createElement('div');
    title.className = 'doomscroll-title';
    title.textContent = 'STOP DOOM SCROLL !!!';

    const sub = document.createElement('div');
    sub.className = 'doomscroll-sub';
    sub.textContent = '1 minute passée sur ce site. Toutes les vidéos sont en pause.';

    const btn = document.createElement('button');
    btn.id = 'doomscroll-continue';
    btn.type = 'button';
    btn.textContent = "OK, encore 1 minute";

    card.appendChild(title);
    card.appendChild(sub);
    card.appendChild(btn);
    overlay.appendChild(card);
    document.documentElement.appendChild(overlay);

    btn.addEventListener('click', () => {
      if (overlay) {
        overlay.remove();
        overlay = null;
      }
      elapsed = 0;
    });
  }

  function trigger() {
    pauseAllVideos();
    sendSystemNotification();
    showOverlay();
  }

  setInterval(() => {
    // Reset du compteur quand l'URL change (YouTube/Instagram/TikTok sont des SPA)
    if (location.href !== lastUrl) {
      lastUrl = location.href;
      elapsed = 0;
      if (overlay) {
        overlay.remove();
        overlay = null;
      }
    }
    elapsed += 1;
    if (elapsed >= LIMIT_SECONDS) {
      trigger();
      elapsed = 0; // re-déclenche toutes les minutes
    }
  }, 1000);
})();
