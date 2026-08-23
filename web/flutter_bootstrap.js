{{flutter_js}}
{{flutter_build_config}}

// Keep the renderer usable when the device cannot reach Google's CDN.
// The Flutter build command copies CanvasKit to build/web/canvaskit/.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "./canvaskit/",
  },
});
