import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'litorjika/screens/litorjika_home_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/vavaka_screen.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {

    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      size: Size(600, 680), 
      minimumSize: Size(600, 680),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Alimanaka',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const LitorziaApp());
}

class LitorziaApp extends StatelessWidget {
  const LitorziaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alimanaka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // 2. AMPIO ETO NY VavakaScreen() (Index 2)
  static const List<Widget> _pages = [
    HomeScreen(),
    LitorjikaHomeScreen(),
    VavakaScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // 3. AMPIO ETO NY BOKOTRA FAHA-3 HO AN'NY VAVAKA
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Olomasina',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Litorjika',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Vavaka',
          ),
        ],
      ),
    );
  }
}