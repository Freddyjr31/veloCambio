import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocambio/core/config/app_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Pantalla a pantalla completa que abre el Smartlink de Adsterra
/// dentro de un WebView de la app.
class SmartlinkWebview extends StatefulWidget {
  const SmartlinkWebview({super.key});

  @override
  State<SmartlinkWebview> createState() => _SmartlinkWebviewState();
}

class _SmartlinkWebviewState extends State<SmartlinkWebview> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _currentUrl = url;
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            final scheme = uri?.scheme ?? '';
            // Las ofertas que salen a otras apps (instalar, tel, etc.)
            // se abren en el navegador externo en vez de romperse en el WebView.
            if (scheme != 'http' && scheme != 'https') {
              launchUrl(uri!, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.adsterraSmartlinkUrl));
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(_currentUrl);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(
        Uri.parse(AppConfig.adsterraSmartlinkUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Abrir en el navegador',
            onPressed: _openInBrowser,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2.5,
              color: Color(0xFF10B981),
            ),
        ],
      ),
    );
  }
}
