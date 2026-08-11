import 'dart:async';

import 'package:flutter/material.dart';
import 'package:velocambio/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1000), _goToMainScreen);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _goToMainScreen() async {
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0B20),
      body: Center(
        child: ClipOval(
          child: SizedBox(
            width: 180,
            height: 180,
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
