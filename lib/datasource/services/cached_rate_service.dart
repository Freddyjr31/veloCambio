import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:velocambio/models/adapters/cached_rate_adapter.dart';

class CachedRateService {
  static const String boxName = 'rate_cache';
  static const String usdOficialKey = 'usd_oficial';
  static const String usdMarketKey = 'usd_market';
  static const String eurKey = 'eur';
  static const String usdtP2pKey = 'usdt_p2p';

  Box<CachedRateModel> get _box => Hive.box<CachedRateModel>(boxName);

  Future<void> save(String key, CachedRateModel rate) async {
    try {
      await _box.put(key, rate);
    } catch (e) {
      log('Error guardando cache [$key]: $e', name: 'CachedRateService');
    }
  }

  CachedRateModel? get(String key) {
    try {
      return _box.get(key);
    } catch (e) {
      log('Error leyendo cache [$key]: $e', name: 'CachedRateService');
      return null;
    }
  }

  void clear() {
    try {
      _box.clear();
    } catch (e) {
      log('Error limpiando cache: $e', name: 'CachedRateService');
    }
  }
}
