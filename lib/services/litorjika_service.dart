import 'dart:convert';
import 'package:flutter/services.dart';

class LitorjikaService {
  static const String _jsonAssetPath = 'assets/json/litorjika.json';

  /// Mamaky ny JSON amim-pahasalamana rehefa Sokafana ny Tab Litorjika
  static Future<dynamic> loadLitorjikaData() async {
    try {
      final String response = await rootBundle.loadString(_jsonAssetPath);
      final data = json.decode(response);
      return data;
    } catch (e) {
      throw Exception('Tsy voavaky ny rakitra JSON litorjika: $e');
    }
  }
}