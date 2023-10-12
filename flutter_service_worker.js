'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"version.json": "da744817da86014106514aca1d2d09b3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/AssetManifest.json": "c41e262f8faeca70fb9ec9014274a085",
"assets/assets/fonts/NotoColorEmoji-Regular.ttf": "1dab949e558621ef302fceb3841c06b3",
"assets/assets/i18n/da_DK.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/ar_SA.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/el_GR.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/hu_HU.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/cs_CZ.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/it_IT.json": "8eb032bf7f8adcea31e48eb75ceb7996",
"assets/assets/i18n/sv_SE.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/fi_FI.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/he_IL.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/pt_BR.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/af_ZA.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/pt_PT.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/ja_JP.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/zh_CN.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/tr_TR.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/uk_UA.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/ca_ES.json": "449884151fa2532a08b959e287a2676e",
"assets/assets/i18n/nl_NL.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/deh_DEH.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/vi_VN.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/fr_FR.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/de_DE.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/es_ES.json": "5a8e34caa0174e2b9016b7ada3ec448e",
"assets/assets/i18n/pl_PL.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/zh_TW.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/no_NO.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/en_US.json": "6682b53c4fab7266ccb616ccdfd1d5ea",
"assets/assets/i18n/ru_RU.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/ko_KR.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/sr_SP.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/assets/i18n/ro_RO.json": "5136a39e15ac27b5c2bc582edc9a5efe",
"assets/AssetManifest.bin": "dc653476141c691786117b83da2e2cf5",
"assets/fonts/MaterialIcons-Regular.otf": "2e09c24adedbc4f8ad78de366639e18b",
"assets/NOTICES": "435115bc05239f277edd1ab90a214512",
"assets/FontManifest.json": "7a144f1857208f9a55ada3f05fd94496",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"icons/Icon-192-maskable.png": "9c3837df4e144c90c7aba2e86e6bdb55",
"icons/apple-touch-icon.png": "b52b18aadd96f4ff2730daedc413d1aa",
"icons/Icon-512-maskable.png": "c9dd1f100e8e880da18edb909249de62",
"icons/Icon-512.png": "7bba17b3b8abc91981158390a645f031",
"icons/Icon-192.png": "bf1e208d8402b7dc50af8d7808f18337",
"index.html": "602eefe04e0b6fb39bdf1282bc200999",
"/": "602eefe04e0b6fb39bdf1282bc200999",
"main.dart.js": "1a1195380f503c610864745e34d18b84",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"favicon.png": "f3f964117eaa40cbfe433b4c984b9b61",
"manifest.json": "6e395c894af6e85687c26b655805bef1"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
