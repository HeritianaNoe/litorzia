import '../core/app_info.dart';
import '../services/liturgical_readings_service.dart';
import '../services/olomasina_service.dart';
import '../services/vavaka_service.dart';
import 'app_database.dart';

/// Mametraka ao anaty RAM (efa voahodina/voamaha) ny angona ilain'ny pejy
/// rehetra MIALOHA ny fisehoan'ny pejy voalohany (mandritra ny splash).
///
/// Vokatra: tsy mila "loading" intsony ny pejy, ka tsy misy spinner na
/// fanavaozana hita rehefa miova pejy (tab na Navigator.push).
class AppData {
  AppData._();

  static Future<void>? _pending;

  static Future<void> init() async {
    final pending = _pending ??= _load();
    try {
      await pending;
    } catch (_) {
      _pending = null; // azo averina ny fanandramana
      rethrow;
    }
  }

  static Future<void> _load() async {
    await AppInfo.load();
    await AppDatabase.instance.open();
    await Future.wait<void>([
      OlomasinaService.instance.load(),
      VavakaService.instance.load(),
      LiturgicalReadingsService.load(),
    ]);
  }
}
