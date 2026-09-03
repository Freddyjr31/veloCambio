import 'package:home_widget/home_widget.dart';
import 'package:velocambio/core/http/dio_client.dart';
import 'package:velocambio/core/utils/truncate.dart';
import 'package:velocambio/models/rate_api_model.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const String _bcvRateKey = 'bcv_rate';
  static const String _bcvDateKey = 'bcv_date';
  static const String _bcvBaseUrlKey = 'bcv_base_url';
  static const String _androidWidgetName = 'BcvRateWidget';

  static Future<void> syncBcvRateToWidget(RateApiResponseModel model) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        _bcvRateKey,
        truncateTo(model.price, 3).toStringAsFixed(3),
      );
      await HomeWidget.saveWidgetData<String>(
        _bcvDateKey,
        _formatDate(model.fetched_at),
      );
      await HomeWidget.saveWidgetData<String>(
        _bcvBaseUrlKey,
        dio.options.baseUrl,
      );
      await HomeWidget.updateWidget(name: _androidWidgetName);
    } catch (_) {}
  }

  static String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'Actualizado: $hour:$minute';
  }
}
