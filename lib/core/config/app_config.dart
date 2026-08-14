import 'package:flutter_dotenv/flutter_dotenv.dart';

const String appEnvironment = String.fromEnvironment(
  'FLUTTER_APP_FLAVOR',
  defaultValue: 'dev',
);

// const String _defaultBaseUrl = 'http://10.0.2.2:9000/';
const String _defaultBaseUrl = 'http://127.0.0.1:9000/';

class AppConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? _defaultBaseUrl;

  static Future<void> loadEnv() async {
    await dotenv.load(
      fileName: 'assets/env/.env.$appEnvironment',
      isOptional: true,
    );
  }
}
