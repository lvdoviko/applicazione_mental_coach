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

  @override
  void initState() {
    super.initState();
    _verifyAvatarFile();
  }

  /// Verify avatar file exists before loading
  Future<void> _verifyAvatarFile() async {
    if (widget.config is! AvatarConfigLoaded) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No avatar configured';
        _isLoading = false;
      });
      return;
    }

    final config = widget.config as AvatarConfigLoaded;
    final file = File(config.localPath);

    if (!await file.exists()) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Avatar file not found';
        _isLoading = false;
      });
      return;
    }

    if (mounted) {
      // Initialize WebView with custom HTML
      _initWebView();
    }
  }

  HttpServer? _server;

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  Future<void> _initWebView() async {
    debugPrint("🏗️ Avvio Localhost Server Strategy (Ultimate)...");

    try {
      final config = widget.config as AvatarConfigLoaded;
      
      // 1. Avvia Server Locale
      await _startLocalServer(config.localPath);
      
      if (_server == null) throw Exception("Server failed to start");
      
      final port = _server!.port;
      
      // FINAL CONFIGURATION: Localhost Server
      final avatarUrl = 'http://127.0.0.1:$port/avatar.glb';
      final animUrl = 'http://127.0.0.1:$port/idle.glb';
      
      debugPrint("🔗 Local Server running on port $port");
      debugPrint("👤 Avatar: $avatarUrl");
      debugPrint("💃 Anim: $animUrl");

      final htmlString = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            /* Sfondo Trasparente per integrazione nativa */
            body, html { 
              margin: 0; 
              height: 100%; 
              overflow: hidden; 
              background: radial-gradient(circle at 50% 30%, #1C2541, #080a10); /* Deep Focus Gradient */
            }
            model-viewer { width: 100%; height: 100%; --poster-color: transparent; }
          </style>
          <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js"></script>
        </head>
        <body>
          <model-viewer 
            id="coach"
            src="$avatarUrl" 
            animation-src="$animUrl"
            crossorigin="anonymous"
            autoplay 
            muted
            camera-controls
            disable-zoom
            disable-pan
            /* Chest-Up View (Safer Zoom) */
            camera-target="0m 1.45m 0m" 
            camera-orbit="0deg 90deg 0.9m"
            field-of-view="30deg"
            
            disable-zoom 
            disable-pan
            min-camera-orbit="auto 90deg auto" 
            max-camera-orbit="auto 90deg auto"
            
            interaction-prompt="none"
            shadow-intensity="1"
            environment-image="neutral"
            exposure="1.2"
          >
          </model-viewer>

          <script>
            const viewer = document.querySelector("#coach");

            viewer.addEventListener('load', () => {
              console.log("✅ MODELLO CARICATO.");
              
              // Tentativo semplice di avvio animazione se disponibile
              if (viewer.availableAnimations.length > 0) {
                  console.log("🎬 Playing: " + viewer.availableAnimations[0]);
                  viewer.animationName = viewer.availableAnimations[0];
                  viewer.play();
              } else {
                  console.log("ℹ️ Nessuna animazione rilevata (Static Mode)");
              }
            });
          </script>
        </body>
        </html>
      ''';

      // Initialize Controller
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setOnConsoleMessage((message) {
           debugPrint('WebView Console: ${message.message}');
        })
        ..loadHtmlString(htmlString); // Non serve baseUrl speciale qui, usiamo http:// assoluti

      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
        });
      }
      debugPrint("🚀 HTML Localhost Caricato");

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

  Future<void> _startLocalServer(String localAvatarPath) async {
    try {
      // Chiudi server precedente se esiste
      _server?.close(force: true);
      
      // Bind su loopback (localhost) porta 0 (random libera)
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      
      _server!.listen((HttpRequest request) async {
        final path = request.uri.path;
        
        // CORS Headers (per sicurezza)
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers.add('Access-Control-Allow-Methods', 'GET');
        
        try {
          if (path == '/avatar.glb') {
            final file = File(localAvatarPath);
            if (await file.exists()) {
              request.response.headers.contentType = ContentType('model', 'gltf-binary');
              await file.openRead().pipe(request.response);
            } else {
              request.response.statusCode = HttpStatus.notFound;
              request.response.close();
            }
          } else if (path == '/idle.glb') {
            final data = await rootBundle.load('assets/animations/idle.glb');
            request.response.headers.contentType = ContentType('model', 'gltf-binary');
            request.response.add(data.buffer.asUint8List());
            await request.response.close();
          } else {
            request.response.statusCode = HttpStatus.notFound;
            request.response.close();
          }
        } catch (e) {
          debugPrint("Server Error: $e");
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


