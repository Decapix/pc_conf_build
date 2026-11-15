chrome.runtime.onMessage.addListener((message) => {
  if (message && message.type === 'doomscroll-alert') {
    let site = 'ce site';
    try {
      const host = new URL(message.url || '').hostname;
      if (host.includes('youtube')) site = 'YouTube Shorts';
      else if (host.includes('instagram')) site = 'Instagram';
      else if (host.includes('tiktok')) site = 'TikTok';
    } catch (e) {
      // ignore
    }
    chrome.notifications.create('doomscroll-' + Date.now(), {
      type: 'basic',
      iconUrl: 'icon128.png',
      title: 'Stop doom scroll !!!',
      message: '1 minute passée sur ' + site + '. Les vidéos sont en pause.',
      priority: 2
    });
  }
});
