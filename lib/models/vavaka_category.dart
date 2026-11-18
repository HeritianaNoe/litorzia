import 'package:flutter/material.dart';

/// Sokajin'ny Vavaka miaraka amin'ny icon mifanaraka aminy
/// (mitovy fomba amin'ny [SokajyCategory] ho an'ny Olomasina).
class VavakaCategory {
  final String label;
  final IconData icon;

  const VavakaCategory({
    required this.label,
    required this.icon,
  });
}

/// Lisitry ny sokajy Vavaka (mifanaraka amin'ny `kategoria` ao amin'ny DB).
const List<VavakaCategory> vavakaCategories = [
  VavakaCategory(
    label: 'Fototra',
    icon: Icons.foundation,
  ),
  VavakaCategory(
    label: 'Finoana',
    icon: Icons.favorite,
  ),
  VavakaCategory(
    label: 'Fiarovana',
    icon: Icons.shield,
  ),
  VavakaCategory(
    label: 'Fanolorana',
    icon: Icons.volunteer_activism,
  ),
  VavakaCategory(
    label: 'Fianakaviana',
    icon: Icons.family_restroom,
  ),
  VavakaCategory(
    label: 'Fihavanana',
    icon: Icons.handshake,
  ),
  VavakaCategory(
    label: 'Fiadanana',
    icon: Icons.spa,
  ),
  VavakaCategory(
    label: 'Fialan-tsasatra',
    icon: Icons.nightlight_round,
  ),
];

/// Mitady ny [VavakaCategory] mifanaraka amin'ny anarana.
VavakaCategory? findVavakaCategory(String label) {
  for (final c in vavakaCategories) {
    if (c.label == label) return c;
  }
  return null;
}
