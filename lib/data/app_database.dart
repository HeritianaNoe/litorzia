import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../core/app_constants.dart';
import '../core/caesar.dart';

/// Mamaha ny soratra voahodina (Caesar) avy ao amin'ny database.
/// `null` => '' (ho an'ny sehatra tsy maintsy misy).
String decryptText(Object? value) => value == null
    ? ''
    : Caesar.decrypt(value as String, AppConstants.caesarKey);

/// Mamaha ny soratra voahodina; mamerina `null` raha NULL ao amin'ny database.
String? decryptNullable(Object? value) => value == null
    ? null
    : Caesar.decrypt(value as String, AppConstants.caesarKey);

/// Mitantana ny database `smc.db` (SQLite, angona voahodina).
///
/// - Ny `assets/db/smc.db` dia voadika indray mandeha ao amin'ny toeram-pitahirizana
///   an'ny app (ary averina raha miova ny [AppConstants.dbAssetVersion]).
/// - Vakiana amin'ny `readOnly`.
/// - Rehefa misokatra dia hamarinina fa mifanaraka ny key (`meta.check`).
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String _versionPrefKey = 'smc_db_asset_version';

  Database? _db;
  Future<Database>? _opening;

  /// Database efa misokatra (aorian'ny [open]).
  Database get db {
    final d = _db;
    if (d == null) {
      throw StateError('AppDatabase.open() tsy mbola tonga.');
    }
    return d;
  }

  Future<Database> open() async {
    final ready = _db;
    if (ready != null) return ready;

    final pending = _opening ??= _openInternal();
    try {
      return await pending;
    } catch (_) {
      _opening = null; // avela hanandrana indray ny "Andramo indray"
      rethrow;
    }
  }

  Future<Database> _openInternal() async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final path = p.join(dir.path, AppConstants.dbFileName);

    await _copyAssetIfNeeded(path);

    final database = await openDatabase(path, readOnly: true);
    try {
      await _verifyKey(database);
    } catch (_) {
      await database.close();
      rethrow;
    }
    _db = database;
    return database;
  }

  Future<void> _copyAssetIfNeeded(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final file = File(path);

    if (prefs.getInt(_versionPrefKey) == AppConstants.dbAssetVersion &&
        await file.exists()) {
      return;
    }

    final data = await rootBundle.load(AppConstants.dbAssetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    // Soratana ao anaty rakitra vonjimaika aloha, mba tsy hisy database
    // tapaka raha tapaka ny fanoratana.
    final tmp = File('$path.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    if (await file.exists()) await file.delete();
    await tmp.rename(path);

    await prefs.setInt(_versionPrefKey, AppConstants.dbAssetVersion);
  }

  Future<void> _verifyKey(Database database) async {
    final rows = await database.query(
      'meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['check'],
    );
    final ok =
        rows.isNotEmpty &&
        decryptText(rows.first['value']) == AppConstants.dbCheckValue;
    if (!ok) {
      throw StateError(
        'smc.db: diso ny key (Caesar) na simba ny database. '
        'Jereo AppConstants.caesarKey sy tool/build_db.py.',
      );
    }
  }
}
