import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  /// Carga el tema guardado al iniciar la app.
  /// Si no hay preferencia guardada, respeta el tema del sistema.
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_prefKey) ?? 0;
    _themeMode = ThemeMode.values[index];
    notifyListeners();
  }

  /// Guarda y aplica el tema seleccionado.
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, mode.index);
  }

  /// Alterna entre claro y oscuro. Si está en system, pasa a oscuro.
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setTheme(newMode);
  }
}
