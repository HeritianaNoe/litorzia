import 'package:flutter/material.dart';

import '../main.dart';

/// Splashscreen an'ny app, hita mandritra ny fanombohana. Ity dia
/// "splash screen" vokarin'ny Flutter mihitsy (Dart widget), tsy
/// miankina amin'ny native code Android/iOS, ka:
///   - HITA MIVANTANA rehefa "flutter run" ianao, tsy mila
///     "dart run flutter_native_splash:create" akory.
///   - Ampiana ny "native splash" (efa voakonfigiora ao amin'ny
///     pubspec.yaml) izay hita fotoana fohy dia fohy mandritra ny
///     fanombohan'ny appli, alohan'ny hisian'ity pejy ity.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/ic_launcher.png',
                width: 140,
                height: 140,
                errorBuilder: (_, __, ___) => Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.church,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Litorjika Katolika',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
