import 'package:flutter/material.dart';

/// Loko iraisan'ny app: Olomasina = jaune fonce + blanc, Vavaka = bleu roi (royal blue).
class AppColors {
  AppColors._();

  // --- Olomasina (jaune fonce sy blanc) ---
  static const Color olomasinaPrimary = Color(0xFFB8860B); // jaune fonce (dark goldenrod)
  static const Color olomasinaPrimaryDark = Color(0xFF8B6508);
  static const Color olomasinaOnPrimary = Colors.white;
  static const Color olomasinaLight = Color(0xFFFFF3D6); // fonon-jaune malefaka ho an'ny background/accent

  // --- Vavaka (bleu roi) ---
  static const Color vavakaPrimary = Color(0xFF4169E1); // bleu roi (royal blue)
  static const Color vavakaPrimaryDark = Color(0xFF2A4BB5);
  static const Color vavakaOnPrimary = Colors.white;
  static const Color vavakaLight = Color(0xFFE3E9FB);

  // --- Litorjika (move/purple, mifanaraka amin'ny loko efa ao anaty pejy) ---
  static const Color litorjikaPrimary = Colors.purple;
  static const Color litorjikaOnPrimary = Colors.white;
}
