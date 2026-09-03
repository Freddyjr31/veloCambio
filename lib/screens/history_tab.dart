import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/core/utils/truncate.dart';
import 'package:velocambio/models/bcv_history_model.dart';
import 'package:velocambio/providers/bcv_history_provider.dart';
import 'package:velocambio/providers/theme_provider.dart';
import 'package:velocambio/widgets/bottom_baner_ad.dart';

/// Pestaña del histórico de tasas BCV.
///
/// Muestra la tasa oficial USD en una tabla descendente
/// (más reciente -> más viejo) con carga perezosa (paginación).
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    //* Carga inicial de la primera página.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BcvHistoryProvider>().fetchHistory();
    });

    //* Lazy loading: carga la siguiente página al acercarse al final.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<BcvHistoryProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Formato de fecha legible (dd/MM/yyyy).
  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  /// Indica si algún registro trae columnas de compra/venta.
  bool _hasBuySell(List<BcvHistoryItem> items) {
    return items.any((item) => item.rate_buy != null || item.rate_sell != null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BcvHistoryProvider>();
    final items = provider.items;
    final hasBuySell = _hasBuySell(items);

    //* Cuerpo según el estado.
    Widget body;

    if (provider.isLoading && items.isEmpty) {
      body = _buildSkeleton(context);
    } else if (provider.haveErrors && items.isEmpty) {
      body = _buildError(context, provider);
    } else {
      body = RefreshIndicator(
        onRefresh: () => provider.fetchHistory(),
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            //* Pie de tabla (footer) al final de la lista.
            if (index == items.length) {
              return _buildFooter(provider);
            }
            return _HistoryRow(
              item: items[index],
              date: _formatDate(items[index].fecha),
              showBuySell: hasBuySell,
            );
          },
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //* Banner de ads
          const BottomBannerAd(),

          //* Titulo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Column(
              spacing: 4,
              children: [
                Text(
                  'Histórico BCV',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Evolución de la tasa oficial en VES',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          //* Encabezado de la tabla
          _HistoryHeader(showBuySell: hasBuySell),

          //* Filas con lazy loading
          Expanded(child: body),
        ],
      ),
    );
  }

  /// Esqueleto de carga inicial.
  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey[50]!.withAlpha(50),
        highlightColor: Colors.grey[50]!.withAlpha(100),
        duration: const Duration(seconds: 1),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withAlpha(20)),
            ),
          );
        },
      ),
    );
  }

  /// Vista de error con reintento.
  Widget _buildError(BuildContext context, BcvHistoryProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Icon(Icons.cloud_off, size: 56, color: Colors.grey[600]),
          Text(
            'No se pudo cargar el histórico',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ElevatedButton.icon(
            onPressed: () => provider.fetchHistory(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Pie de tabla: indicador de carga o fin del histórico.
  Widget _buildFooter(BcvHistoryProvider provider) {
    if (provider.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (!provider.hasMore && provider.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Fin del historial',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}

/// Encabezado fijo de la tabla.
class _HistoryHeader extends StatelessWidget {
  final bool showBuySell;

  const _HistoryHeader({required this.showBuySell});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.grey[500],
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('FECHA', style: headerStyle)),
          Expanded(
            child: Text(
              'TASA (VES)',
              textAlign: TextAlign.end,
              style: headerStyle,
            ),
          ),
          if (showBuySell) ...[
            Expanded(
              child: Text(
                'COMPRA',
                textAlign: TextAlign.end,
                style: headerStyle,
              ),
            ),
            Expanded(
              child: Text(
                'VENTA',
                textAlign: TextAlign.end,
                style: headerStyle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Fila de la tabla con un registro del histórico.
class _HistoryRow extends StatelessWidget {
  final BcvHistoryItem item;
  final String date;
  final bool showBuySell;

  const _HistoryRow({
    required this.item,
    required this.date,
    required this.showBuySell,
  });

  /// Formatea un valor de tasa (o "—" si es nulo).
  String _formatRate(double? value) =>
      value != null ? truncateTo(value, 3).toStringAsFixed(3) : '—';

  @override
  Widget build(BuildContext context) {

    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.isDark ? primaryColor.withAlpha(20) : Theme.of(context).colorScheme.onSurface.withAlpha(20), width: 1),
      ),
      child: Row(
        children: [
          //* Fecha
          Expanded(
            flex: 2,
            child: Text(date, style: Theme.of(context).textTheme.bodyMedium),
          ),

          //* Tasa principal
          Expanded(
            child: Text(
              _formatRate(item.price),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          //* Compra / Venta (opcional)
          if (showBuySell) ...[
            Expanded(
              child: Text(
                _formatRate(item.rate_buy),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(
                _formatRate(item.rate_sell),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
