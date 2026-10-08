import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:velocambio/core/config/app_config.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/widgets/smartlink_webview.dart';

/// Tarjeta "Ofertas" que abre el Smartlink de Adsterra en un WebView.
///
/// Se muestra junto a las tarjetas de tasas, solo en dispositivos moviles
/// (Android/iOS) y cuando exista una URL configurada en el entorno.
class SmartlinkCard extends StatelessWidget {
  const SmartlinkCard({super.key});

  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get _isEnabled =>
      _isMobile && AppConfig.adsterraSmartlinkUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_isEnabled) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = screenSize.width * 0.9;
    final bgColor = isDark
        ? surfaceColor
        : Theme.of(context).colorScheme.surfaceContainer;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size / 5.2 * textScale),
        child: Container(
          width: size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SmartlinkWebview(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(isDark ? 40 : 25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.campaign,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ofertas para ti',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Apoya la app gratis',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.grey[500]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
