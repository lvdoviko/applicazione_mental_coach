import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service responsible for managing the 3D Avatar WebView and Local Server.
/// It keeps the controller alive to allow instant transitions between screens.
class AvatarEngine extends ChangeNotifier {
  WebViewController? _controller;
  HttpServer? _server;
  bool _isInitialized = false;
  
  WebViewController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  /// Initialize the engine (Server + WebView)
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint("🏗️ [AvatarEngine] Starting Initialization...");

    try {
      // 1. Start Local Server
      await _startLocalServer();
      if (_server == null) throw Exception("Server failed to start");

      // 2. Initialize Controller
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              debugPrint('📦 [AvatarEngine] Page Loaded: $url');
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('❌ [AvatarEngine] Web Resource Error: ${error.description}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'AvatarLoadChannel',
          onMessageReceived: (JavaScriptMessage message) {
            if (message.message == 'loaded') {
              debugPrint("✅ [AvatarEngine] JS Signal: Avatar Loaded");
              if (!_avatarLoadedCompleter.isCompleted) {
                _avatarLoadedCompleter.complete();
              }
            }
          },
        );

      _isInitialized = true;
      notifyListeners(); // Notify listeners that controller is ready
      debugPrint("✅ [AvatarEngine] Initialized Successfully");
      
    } catch (e) {
      debugPrint("❌ [AvatarEngine] Initialization Error: $e");
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  Completer<void> _avatarLoadedCompleter = Completer<void>();

  /// Wait for the Avatar to be visually loaded in the WebView
  Future<void> waitForAvatarLoad() => _avatarLoadedCompleter.future;

  /// Load the Avatar and Background into the WebView
  Future<void> loadContent({
    required String? avatarUrl,
    required String animationAsset, // e.g., 'assets/animations/idle.glb'
  }) async {
    if (_controller == null || _server == null) return;

    // Reset completer for new load
    _avatarLoadedCompleter = Completer<void>();

    try {
      final port = _server!.port;
      
      // Load Animation
      final animBytes = await rootBundle.load(animationAsset)
          .then((b) => b.buffer.asUint8List());
      final animUri = 'data:model/gltf-binary;base64,${base64Encode(animBytes)}';

      debugPrint("🔗 [AvatarEngine] Loading URL: $avatarUrl");

      final htmlString = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
          html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; }
          
          .background-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('http://127.0.0.1:$port/sfondo_chat.png');
            background-size: cover;
            background-position: center;
            z-index: 0;
            filter: blur(8px);
            transform: scale(1.1);
          }
          model-viewer { 
            position: absolute;
            top: 0;
            left: 0;
            width: 100%; 
            height: 100%; 
            background-color: transparent;
            z-index: 1; 
            --poster-color: transparent;
          }
        </style>
          <script type="module" src="http://127.0.0.1:$port/model-viewer.min.js"></script>
        </head>
        <body>
          <div class="background-image"></div>
          
          <model-viewer 
            id="coach"
            src="$avatarUrl" 
            animation-src="$animUri"
            autoplay 
            muted
            camera-target="0m 1.62m 0m" 
            field-of-view="20deg"
            camera-orbit="0deg 90deg 2m"
            disable-zoom 
            disable-pan
            min-camera-orbit="auto 90deg auto" 
            max-camera-orbit="auto 90deg auto"
            exposure="1.2" 
            environment-image="neutral" 
            shadow-intensity="1.5"
            shadow-softness="1"
            style="width: 100%; height: 100%;"
          >
          </model-viewer>

          <script>
            console.log("🔍 JS STARTED");
            const viewer = document.querySelector("#coach");
            
            viewer.addEventListener('load', () => {
              console.log("✅ Avatar Online Caricato.");
              // Notify Flutter
              if (window.AvatarLoadChannel) {
                window.AvatarLoadChannel.postMessage('loaded');
              }
            });

            viewer.addEventListener('error', (e) => {
              console.log("❌ MODEL ERROR: " + JSON.stringify(e.detail));
              viewer.style.display = 'none';
              // Also complete on error to avoid hanging
              if (window.AvatarLoadChannel) {
                window.AvatarLoadChannel.postMessage('loaded'); 
              }
            });
          </script>
        </body>
        </html>
      ''';

      await _controller?.loadHtmlString(htmlString);
      debugPrint("🚀 [AvatarEngine] HTML Content Loaded");

    } catch (e) {
      debugPrint("❌ [AvatarEngine] Load Content Error: $e");
      // Ensure we don't hang if something catastrophic happens
      if (!_avatarLoadedCompleter.isCompleted) {
        _avatarLoadedCompleter.complete();
      }
    }
  }

  Future<void> _startLocalServer() async {
    try {
      _server?.close(force: true);
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      
      _server!.listen((HttpRequest request) async {
        final path = request.uri.path;
        // debugPrint("📥 Server Request: $path"); 
        
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers.add('Access-Control-Allow-Methods', 'GET');
        
        try {
          if (path == '/sfondo_chat.png') {
            final data = await rootBundle.load('assets/images/sfondo_chat.png');
            request.response.headers.contentType = ContentType('image', 'png');
            request.response.add(data.buffer.asUint8List());
            await request.response.close();
          } else if (path == '/model-viewer.min.js') {
            final data = await rootBundle.load('assets/js/model-viewer.min.js');
            request.response.headers.contentType = ContentType('text', 'javascript');
            request.response.add(data.buffer.asUint8List());
            await request.response.close();
          } else {
            request.response.statusCode = HttpStatus.notFound;
            request.response.close();
          }
        } catch (e) {
          debugPrint("Server Error ($path): $e");
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.close();
        }
      });
    } catch (e) {
      debugPrint("❌ Errore avvio server: $e");
    }
  }

  @override
  void dispose() {
    _server?.close(force: true);
    _controller = null;
    _isInitialized = false;
    super.dispose();
  }
}

/// Provider for the AvatarEngine (Singleton, KeepAlive)
final avatarEngineProvider = ChangeNotifierProvider<AvatarEngine>((ref) {
  final engine = AvatarEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});
