import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../main.dart';

/// Splashscreen an'ny app, hita mandritra ny fanombohana.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Fanamboarana ny AnimationController (maharitra 1.2 segondra)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Animation fivoahana tsimbadika (Fade In)
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Animation fihalehibeazana moramora (Scale Up)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Mandefa ny animation
    _animationController.forward();

    _boot();
  }

  /// Mamaky sy mamaha ny angona (database voahodina -> RAM) mandritra ny
  /// splash, ary mamindra ho amin'ny MainNavigation rehefa vita ny roa:
  /// ny fotoana ahatomombanan'ny animation (2.5 segondra) SY ny angona.
  /// Vokatra: tsy mila "loading" intsony ny pejy aorian'izay.
  Future<void> _boot() async {
    try {
      await Future.wait<void>([
        AppData.init(),
        Future<void>.delayed(const Duration(milliseconds: 2500)),
      ]);
      if (!mounted) return;
      // Fading ny fialan'ny splashscreen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  void _andramoIndray() {
    setState(() => _error = null);
    _boot();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Sary fond ho an'ny splash screen
          Image.asset(
            'assets/images/lt.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.deepPurple.shade900),
          ),
          // Aloka miloko volomparasy eo ambonin'ny sary mba hamakiana tsara ny soratra
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade900.withAlpha(217),
                  Colors.deepPurple.shade900.withAlpha(153),
                  Colors.purple.shade900.withAlpha(217),
                ],
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo miaraka amin'ny aloka (Shadow)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(76),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/ic_launcher.png',
                          width: 130,
                          height: 130,
                          errorBuilder: (_, __, ___) => Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.church,
                              size: 64,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Lohatenin'ny App
                    const Text(
                      'ALIMANAKA KATOLIKA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Litorjika sy Vavaka ary Rakitry ny Olomasina',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(204),
                        letterSpacing: 1.1,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (_error == null)
                      // Progress Indicator miloko fotsy
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Tsy afaka namaky ny angona.\n\n$_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _andramoIndray,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Andramo indray'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
