import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:velocambio/providers/cmm_general_provider.dart';
// Importa tu LoggerService aquí

enum ConnectivityStatus { isConnected, isDisconnected, notDetermined }

class ConnectivityProvider extends CmmGeneralProvider {

  ConnectivityStatus _status = ConnectivityStatus.notDetermined;
  StreamSubscription? _subscription;
  // Getter para leer el estado desde la UI
  ConnectivityStatus get status => _status;

  ConnectivityProvider() {
    _init();
  }

  void _init() async {
    // Verificar estado inicial
    final result = await Connectivity().checkConnectivity();
    _updateStatus(result);

    // Escuchar cambios futuros
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    ConnectivityStatus newStatus;

    if (results.contains(ConnectivityResult.none)) {
      newStatus = ConnectivityStatus.isDisconnected;
    } else {
      newStatus = ConnectivityStatus.isConnected;
    }

    // Solo actualizamos y notificamos si el estado realmente cambió
    if (_status != newStatus) {
      _status = newStatus;
      debugPrint("Estado de red: $_status"); // Reemplaza con tu LoggerService
      notifyListeners(); // Esta es la clave en Provider
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}