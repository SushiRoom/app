'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"favicon.png": "f3f964117eaa40cbfe433b4c984b9b61",
"icons/Icon-192.png": "bf1e208d8402b7dc50af8d7808f18337",
"icons/Icon-512-maskable.png": "c9dd1f100e8e880da18edb909249de62",
"icons/Icon-192-maskable.png": "9c3837df4e144c90c7aba2e86e6bdb55",
"icons/Icon-512.png": "7bba17b3b8abc91981158390a645f031",
"icons/apple-touch-icon.png": "b52b18aadd96f4ff2730daedc413d1aa",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "c70473f28f2f1dbf0da438933a4e9f87",
"assets/assets/i18n/ru_RU.json": "4168c7133030c232cf5fe79c0cb57c64",
"assets/assets/i18n/en_US.json": "78931bcb689b41cc38a06c40086d3762",
"assets/assets/i18n/ja_JP.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/pt_BR.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/pt_PT.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/uk_UA.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/de_DE.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/ca_ES.json": "0280c7e4d42c3966ad72ce8798547dcf",
"assets/assets/i18n/ar_SA.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/sv_SE.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/sr_SP.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/no_NO.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/el_GR.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/da_DK.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/nl_NL.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/it_IT.json": "28278ba2b77517c56c54b08ddd8907f5",
"assets/assets/i18n/pl_PL.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/tr_TR.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/vi_VN.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/af_ZA.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/zh_TW.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/zh_CN.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/he_IL.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/fi_FI.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/es_ES.json": "f8c3366365010036430dcaed7a8e5142",
"assets/assets/i18n/cs_CZ.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/deh_DEH.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/ko_KR.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/hu_HU.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/assets/i18n/ro_RO.json": "990f8e361f6eeac299408c7edd292eba",
"assets/assets/i18n/fr_FR.json": "92d46271546c4b8beb90307009b8a7ac",
"assets/AssetManifest.json": "239c443785f79a2a8dee31f00d54d037",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/fonts/MaterialIcons-Regular.otf": "0108e1493ef088a4786f879b190b9008",
"assets/NOTICES": "644211cb5ae2586282992be7c1505816",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"index.html": "4ca9c207ba2af11a4081b0b9ea65fbd0",
"/": "4ca9c207ba2af11a4081b0b9ea65fbd0",
"main.dart.js": "d295eabb7bedaeaad6f02bad9f70e54d",
"manifest.json": "6e395c894af6e85687c26b655805bef1",
"version.json": "c7233eab9bcd3ee97d89451a6079fbb2",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
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
