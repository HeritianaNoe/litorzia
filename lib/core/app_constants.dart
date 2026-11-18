/// Constantes iraisana an'ny app.
class AppConstants {
  AppConstants._();

  /// Fanalahidin'ny cryptage Caesar ampiasaina amin'ny angona ao anaty `smc.db`.
  /// TENA IZY: tsy maintsy mitovy amin'ny `KEY` ao amin'ny `tool/build_db.py`.
  static const String caesarKey = 'zakaranda';

  /// Lalan'ny database voahodina ao anaty assets.
  static const String dbAssetPath = 'assets/db/smc.db';

  /// Anaran'ny rakitra database rehefa voadika ao amin'ny finday/PC.
  static const String dbFileName = 'smc.db';

  /// Version an'ny database ao anaty assets. ASIO +1 isaky ny mamorona
  /// `smc.db` vaovao (`python3 tool/build_db.py`), mba hosoloana ny kopia
  /// efa ao amin'ny finday. Vakin'ny `tool/build_db.py` ihany koa ity isa ity.
  static const int dbAssetVersion = 1;

  /// Soratra fanamarinana voatahiry (voahodina) ao amin'ny `meta.check`.
  /// Raha tsy mitovy rehefa vakiana ny database dia midika fa diso ny key.
  static const String dbCheckValue = 'SMC-OK';
}
