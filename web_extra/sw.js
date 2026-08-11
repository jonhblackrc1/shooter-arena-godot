// Minimal service worker so the Godot web build is an installable PWA (for PWABuilder / Add to Home Screen).
const CACHE = 'sa-godot-v1';
self.addEventListener('install', (e) => { self.skipWaiting(); });
self.addEventListener('activate', (e) => { e.waitUntil(self.clients.claim()); });
self.addEventListener('fetch', (e) => {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    caches.open(CACHE).then((c) =>
      c.match(e.request).then((hit) =>
        hit || fetch(e.request).then((res) => {
          try { if (res && res.ok && new URL(e.request.url).origin === location.origin) c.put(e.request, res.clone()); } catch (_) {}
          return res;
        })
      )
    )
  );
});
