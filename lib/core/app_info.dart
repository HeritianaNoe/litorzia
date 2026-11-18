import 'package:package_info_plus/package_info_plus.dart';

/// Version an'ny app, vakiana indray mandeha mialoha ny fisehoan'ny pejy
/// (jereo `AppData.init`) mba tsy hisy `setState` / fanavaozana hita
/// rehefa miova pejy.
class AppInfo {
  AppInfo._();

  static String version = '...';

  static Future<void> load() async {
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      // Tsy mampitsahatra ny app ny version tsy hita.
    }
  }
}
