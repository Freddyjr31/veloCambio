import 'dart:developer';

import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/bcv_history_api.dart';
import 'package:velocambio/models/bcv_history_model.dart';

/// Proveedor del histórico de tasas BCV.
///
/// Gestiona la paginación con carga perezosa (lazy loading):
/// - [fetchHistory]: resetea y carga la primera página (más reciente).
/// - [loadMore]: agrega la siguiente página (más antigua) al final.
///
/// La API devuelve cada página en orden **descendente** (más reciente primero)
/// y `page=1` es la más reciente, por lo que no se aplica ninguna inversión.
class BcvHistoryProvider extends CmmGeneralProvider {
  final BcvHistoryApi _historyApi = BcvHistoryApi();

  static const int _pageSize = 50;

  /// Registros ya ordenados de forma descendente (más reciente -> más viejo).
  List<BcvHistoryItem> items = [];

  int currentPage = 0;
  int totalPages = 0;
  int total = 0;

  /// Indica si hay más páginas por cargar.
  bool get hasMore => currentPage < totalPages && totalPages > 0;

  /// Bandera para el indicador de "cargando más" (footer de la tabla).
  bool isLoadingMore = false;

  /// Carga la primera página reseteando el listado completo.
  Future<void> fetchHistory() async {
    super.setLoadingStatus(true);
    items = [];
    currentPage = 0;
    totalPages = 0;
    total = 0;
    isLoadingMore = false;
    notifyListeners();

    try {
      final resp = await _historyApi.getHistory(page: 1, pageSize: _pageSize);

      totalPages = resp.total_pages;
      total = resp.total;
      currentPage = resp.page;

      //* La API ya trae la página ordenada de más reciente a más vieja.
      items = resp.history;
    } catch (e) {
      log('Error en fetchHistory: $e', name: 'BCV HISTORY PROVIDER');
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }
  }

  /// Carga la siguiente página y la agrega al final (datos más antiguos).
  Future<void> loadMore() async {
    if (!hasMore || isLoading || isLoadingMore) return;

    final nextPage = currentPage + 1;
    isLoadingMore = true;
    notifyListeners();

    try {
      final resp = await _historyApi.getHistory(
        page: nextPage,
        pageSize: _pageSize,
      );

      currentPage = resp.page;
      totalPages = resp.total_pages;
      total = resp.total;

      items = [...items, ...resp.history];
    } catch (e) {
      log('Error en loadMore: $e', name: 'BCV HISTORY PROVIDER');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  @override
  void disposeValues() {
    super.disposeValues();
    items = [];
    currentPage = 0;
    totalPages = 0;
    total = 0;
    isLoadingMore = false;
  }
}
