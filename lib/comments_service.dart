import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Kilasy mitantana ny fitahirizana maharitra (persistent) ny commentaire
/// ataon'ny mpampiasa isaky ny fisehoan-javatra litorjika iray.
///
/// Ny commentaire rehetra dia voatahiry ao anaty "map" iray, mifototra
/// amin'ny "id" tokana ho an'ny fisehoan-javatra tsirairay (code + daty),
/// ary voatahiry amin'ny endrika JSON ao anaty SharedPreferences.
class CommentsService {
  static const String _storageKey = 'litorzia_comments';

  /// Mamorona "id" tokana ho an'ny fisehoan-javatra iray, mifototra amin'ny
  /// code sy ny daty (satria mety mitovy code amin'ny taona samihafa).
  static String buildId(String code, DateTime date) {
    final d = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${code}_$d';
  }

  /// Mamaky ny commentaire rehetra voatahiry
  static Future<Map<String, String>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};
    final Map<String, dynamic> decoded = jsonDecode(raw);
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  /// Mamaky ny commentaire iray manokana ho an'ny "id" iray
  static Future<String?> getComment(String id) async {
    final all = await _loadAll();
    return all[id];
  }

  /// Mitahiry (na manova) ny commentaire ho an'ny "id" iray.
  /// Raha banga ny comment, dia esorina tsotra izao ao amin'ny fitahirizana.
  static Future<void> saveComment(String id, String comment) async {
    final all = await _loadAll();
    if (comment.trim().isEmpty) {
      all.remove(id);
    } else {
      all[id] = comment.trim();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(all));
  }
}
