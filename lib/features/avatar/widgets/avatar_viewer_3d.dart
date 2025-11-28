import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';

/// 3D Avatar Viewer with Local-First loading
/// 
/// Features:
/// - Loads .glb from local file system (offline support)
/// - Applies external animations via animation-src
/// - Configurable camera controls
/// - Error fallback to placeholder
class AvatarViewer3D extends StatefulWidget {
  final AvatarConfig config;
  final double? width;
  final double? height;
  final bool enableCameraControls;
  final bool autoRotate;
  final String? animationName; // 'idle' or 'talking'

  const AvatarViewer3D({
    super.key,
    required this.config,
    this.width,
    this.height,
    this.enableCameraControls = false,
    this.autoRotate = false,
    this.animationName,
  });

  @override
  State<AvatarViewer3D> createState() => _AvatarViewer3DState();
}

class _AvatarViewer3DState extends State<AvatarViewer3D> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  WebViewController? _controller;
  bool _useFallback = false;

  @override
  void initState() {
    super.initState();
    _verifyAvatarFile();
  }

  /// Verify avatar file exists before loading
  /// Verify avatar file exists before loading
  Future<void> _verifyAvatarFile() async {
    // HYBRID MODE: Skip local checks, go straight to initialization
    if (mounted) {
      _initWebView();
    }
  }

  HttpServer? _server;

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  void didUpdateWidget(AvatarViewer3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config != oldWidget.config) {
      _loadAvatar();
    }
  }

  Future<void> _initWebView() async {
    debugPrint("🏗️ Avvio Caricamento IBRIDO (Avatar Online + Risorse Locali)...");

    try {
      // 1. Avvia Server Locale (per lo sfondo)
      await _startLocalServer();
      if (_server == null) throw Exception("Server failed to start");
      
      // Initialize Controller
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setOnConsoleMessage((message) {
           debugPrint('WebView Console: ${message.message}');
        });

      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }

      // 2. Carica Contenuto
      await _loadAvatar();

    } catch (e) {
      debugPrint("❌ Errore Caricamento: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load avatar';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAvatar() async {
    if (_controller == null || _server == null) return;
    
    try {
      final port = _server!.port;

      // 2. URL AVATAR
      String avatarUrl = "https://models.readyplayer.me/69286d45132e61458cee2d1f.glb?bodyType=fullbody&quality=high"; 
      if (widget.config is AvatarConfigLoaded) {
        avatarUrl = (widget.config as AvatarConfigLoaded).remoteUrl;
      }
      
      // 3. CARICA ANIMAZIONE (Da Asset -> Base64)
      final animBytes = await rootBundle.load('assets/animations/idle.glb')
          .then((b) => b.buffer.asUint8List());
      final animUri = 'data:model/gltf-binary;base64,${base64Encode(animBytes)}';

      // 4. CARICA SFONDO (Dal Server Locale)
      final bgImage = "http://127.0.0.1:$port/sfondo_chat.png";

      debugPrint("🔗 Avatar URL: $avatarUrl");
      debugPrint("🔗 Local Server running on port $port");

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
          <!-- Usa model-viewer locale se possibile, altrimenti CDN -->
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
            
            /* 1. PUNTA AGLI OCCHI (Non al centro del corpo) */
            camera-target="0m 1.62m 0m" 
            
            /* 2. ZOOM TELEOBIETTIVO (Taglia le gambe e riempie lo schermo) */
            field-of-view="20deg"
            
            /* 3. POSIZIONE FISICA (Distanza fissa) */
            camera-orbit="0deg 90deg 2m"
            
            /* 4. BLOCCA MOVIMENTI UTENTE (Per non rovinare l'inquadratura) */
            disable-zoom 
            disable-pan
            min-camera-orbit="auto 90deg auto" 
            max-camera-orbit="auto 90deg auto"
            
            /* 5. ILLUMINAZIONE STUDIO (Ciliegina sulla torta) */
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
            
            // SCRIPT "BLIND FORCE" PER ANIMAZIONE
            viewer.addEventListener('load', () => {
              console.log("✅ Avatar Online Caricato.");
            });

            viewer.addEventListener('error', (e) => {
              console.log("❌ MODEL ERROR: " + JSON.stringify(e.detail));
              // Hide viewer on error to show background
              viewer.style.display = 'none';
            });
          </script>
        </body>
        </html>
      ''';

      await _controller?.loadHtmlString(htmlString);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint("🚀 HTML Ibrido (Online Avatar) Caricato");

    } catch (e) {
      debugPrint("❌ Errore Caricamento Avatar: $e");
    }
  }

  Future<void> _startLocalServer() async {
    try {
      // Chiudi server precedente se esiste
      _server?.close(force: true);
      
      // Bind su loopback (localhost) porta 0 (random libera)
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      
      _server!.listen((HttpRequest request) async {
        final path = request.uri.path;
        debugPrint("📥 Server Request: $path"); // Debug log
        
        // CORS Headers (per sicurezza)
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers.add('Access-Control-Allow-Methods', 'GET');
        
        try {
          if (path == '/sfondo_chat.png') {
            debugPrint("🖼️ Serving background image");
            final data = await rootBundle.load('assets/images/sfondo_chat.png');
            request.response.headers.contentType = ContentType('image', 'png');
            request.response.add(data.buffer.asUint8List());
            await request.response.close();
          } else if (path == '/model-viewer.min.js') {
            debugPrint("📜 Serving model-viewer.min.js");
            final data = await rootBundle.load('assets/js/model-viewer.min.js');
            request.response.headers.contentType = ContentType('text', 'javascript');
            request.response.add(data.buffer.asUint8List());
            await request.response.close();
          } else {
            debugPrint("❌ Not Found: $path");
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
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorPlaceholder();
    }

    if (_isLoading) {
      return _buildLoadingPlaceholder();
    }

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: _controller != null 
        ? WebViewWidget(controller: _controller!)
        : const SizedBox(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading coach...',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.secondary.withOpacity(0.3),
                ],
              ),
            ),
            child: const Icon(
              Icons.psychology,
              size: 30,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Coach Avatar',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                _errorMessage!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


