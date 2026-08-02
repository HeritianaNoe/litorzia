import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/olomasina_model.dart';

/// Service hitantanana ny famakiana ny rakitra JSON "olomasina.json"
class OlomasinaJsonService {
  OlomasinaJsonService._privateConstructor();
  static final OlomasinaJsonService instance = OlomasinaJsonService._privateConstructor();

  static const String _jsonPath = "assets/json/olomasina.json";

  // Cache ho an'ny RAM mba tsy averimberina vakiana ao amin'ny assets ny JSON
  List<Olomasina>? _cachedList;

  /// Mamaky ny JSON ary mamerina ny lisitry ny Olomasina rehetra
  Future<List<Olomasina>> getOlomasinaRehetra() async {
    // Raha efa voavaky teo aloha ny JSON dia ampiasaina mivantana amin'ny RAM
    if (_cachedList != null) {
      return _cachedList!;
    }

    try {
      final String response = await rootBundle.loadString(_jsonPath);
      final List<dynamic> data = json.decode(response);

      _cachedList = data.map((jsonMap) => Olomasina.fromMap(jsonMap)).toList();
      
      // Mandahatra azy araka ny anarana (A-Z)
      _cachedList!.sort((a, b) => a.anarana.compareTo(b.anarana));

      return _cachedList!;
    } catch (e) {
      throw Exception('Tsy voavaky ny rakitra JSON ($_jsonPath): $e');
    }
  }

  /// Mikaroka Olomasina araka ny teny voasoratra (anarana, sokajy, na fanoharana)
  Future<List<Olomasina>> karohyOlomasina(String teny) async {
    final list = await getOlomasinaRehetra();
    if (teny.trim().isEmpty) return list;

    final query = teny.toLowerCase();
    return list.where((olomasina) {
      final anaranaMatch = olomasina.anarana.toLowerCase().contains(query);
      final sokajyMatch = olomasina.sokajy.toLowerCase().contains(query);
      final fanoharanaMatch = olomasina.fanoharana.toLowerCase().contains(query);

      return anaranaMatch || sokajyMatch || fanoharanaMatch;
    }).toList();
  }

  /// Mamerina ny Olomasina iray araka ny ID-ny
  Future<Olomasina?> getOlomasinaAmin(int id) async {
    final list = await getOlomasinaRehetra();
    try {
      return list.firstWhere((olomasina) => olomasina.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mamerina ny Olomasina fankalazaina amin'ny daty voatondro
  Future<List<Olomasina>> getOlomasinaAminNyDaty(String daty) async {
    final list = await getOlomasinaRehetra();
    return list.where((olomasina) => 
      olomasina.datyFankalazana.toLowerCase().contains(daty.toLowerCase())
    ).toList();
  }

  /// Mamafa ny Cache raha te-hanery ny app hamaky indray ny JSON
  void clearCache() {
    _cachedList = null;
  }
}