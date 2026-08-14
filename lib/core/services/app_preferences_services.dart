import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Intentamos obtener el valor de 'is_first_time'.
    // Si es nulo (??), significa que nunca se ha guardado, por lo tanto es true.
    bool isFirst = prefs.getBool('is_first_time') ?? true;

    if (isFirst) {
      // Si fue la primera vez, guardamos 'false' de inmediato
      // para que la próxima vez ya no entre aquí.
      await prefs.setBool('is_first_time', false);
    }

    return isFirst;
  }
}
