import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';

import 'core/providers/app_providers.dart';
import 'screens/index.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MultiProvider(
        providers: AppProviders.providers,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
