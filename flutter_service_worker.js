'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-512.png": "7bba17b3b8abc91981158390a645f031",
"icons/Icon-192.png": "bf1e208d8402b7dc50af8d7808f18337",
"icons/Icon-512-maskable.png": "c9dd1f100e8e880da18edb909249de62",
"icons/apple-touch-icon.png": "b52b18aadd96f4ff2730daedc413d1aa",
"icons/Icon-192-maskable.png": "9c3837df4e144c90c7aba2e86e6bdb55",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"flutter_bootstrap.js": "32f2d937caf13f0377738b013e85ee35",
"version.json": "494dcde68675861e1582c58ac0dee3dc",
"favicon.png": "f3f964117eaa40cbfe433b4c984b9b61",
"style.css": "75004ee2468baae9fb522d3d1d680a54",
"main.dart.js": "75a98df4a316616803ad42e55d8d5b2b",
"assets/NOTICES": "1ac88e1e085f4e46c78908fd246da659",
"assets/AssetManifest.bin": "dba91d9ab81febe577a21dc60c9df7e6",
"assets/assets/i18n/fi_FI.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/uk_UA.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/pl_PL.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/he_IL.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/deh_DEH.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/pt_PT.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/hu_HU.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/cs_CZ.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/sr_SP.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/ca_ES.json": "22d734636f022ee660ba8f84cc465b40",
"assets/assets/i18n/es_ES.json": "79217352cfbf91f8bed0cf08ffb004b5",
"assets/assets/i18n/ro_RO.json": "adf34b8bf9ec19a73218889de2c4cdd4",
"assets/assets/i18n/sv_SE.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/en_US.json": "2e9efffa7d9ce1a2a841443703f132d7",
"assets/assets/i18n/pt_BR.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/de_DE.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/tr_TR.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/ar_SA.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/ru_RU.json": "6b7c58532ddf76f3501159cfac0acd69",
"assets/assets/i18n/fr_FR.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/da_DK.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/zh_CN.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/ko_KR.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/ja_JP.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/no_NO.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/zh_TW.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/el_GR.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/af_ZA.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/it_IT.json": "a41e7fa530c4e0699663649779b1dba2",
"assets/assets/i18n/nl_NL.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/assets/i18n/vi_VN.json": "71c691b83224b312cdfb9a9e325226b0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/syncfusion_flutter_pdfviewer/assets/highlight.png": "7384946432b51b56b0990dca1a735169",
"assets/packages/syncfusion_flutter_pdfviewer/assets/underline.png": "c94a4441e753e4744e2857f0c4359bf0",
"assets/packages/syncfusion_flutter_pdfviewer/assets/squiggly.png": "c9602bfd4aa99590ca66ce212099885f",
"assets/packages/syncfusion_flutter_pdfviewer/assets/strikethrough.png": "cb39da11cd936bd01d1c5a911e429799",
"assets/AssetManifest.bin.json": "c049b6580c14414537a53018a7933cc9",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "b824e5b9a98f73eae45abe3bdab35cce",
"assets/AssetManifest.json": "ee2914e2c3adb448f5a314ad311a6f14",
"index.html": "dfddfc2aec1710a1b598afbc7126bac8",
"/": "dfddfc2aec1710a1b598afbc7126bac8",
"manifest.json": "6e395c894af6e85687c26b655805bef1"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
