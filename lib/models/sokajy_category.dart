import 'package:flutter/material.dart';

/// Mirakitra ny fifandraisan'ny sokajy Olomasina (JSON: "sokajy")
/// amin'ny icon Flutter (Material Icons) mba hamoronana pejy grid azo
/// tsindriana hisivanana Olomasina araka ny sokajiny.
class SokajyCategory {
  final String label;

  /// Ny icon Flutter (Material Icons) mifandraika amin'ity sokajy ity.
  final IconData icon;

  /// Ireo soatoavina "sokajy" ao amin'ny olomasina.json mifandray amin'ity
  /// sokajy ity (azo mitambatra maromaro ao anaty tile iray)
  final List<String> sokajyValues;

  const SokajyCategory({
    required this.label,
    required this.icon,
    required this.sokajyValues,
  });
}

const List<SokajyCategory> sokajyCategories = [
  SokajyCategory(
    label: 'Masina',
    icon: Icons.church,
    sokajyValues: ['Masina Lehibe', 'Masina'],
  ),
  SokajyCategory(
    label: 'Apostoly sy Misionera',
    icon: Icons.public,
    sokajyValues: ['Apostoly', 'Misionera'],
  ),
  SokajyCategory(
    label: 'Mpampianatra ny Fiangonana',
    icon: Icons.school,
    sokajyValues: ['Mpampianatra ny Fiangonana'],
  ),
  SokajyCategory(
    label: 'Mpanorina Ordina',
    icon: Icons.account_balance,
    sokajyValues: ['Mpanorina Ordina', 'Relijiozy'],
  ),
  SokajyCategory(
    label: 'Martiry',
    icon: Icons.local_fire_department,
    sokajyValues: ['Martiry'],
  ),
  SokajyCategory(
    label: 'Virijiny',
    icon: Icons.local_florist,
    sokajyValues: ['Virijiny'],
  ),

  SokajyCategory(
    label: 'Relijiozy',
    icon: Icons.groups,
    sokajyValues: ['Relijiozy'],
  ),
  SokajyCategory(
    label: 'Mpanabe',
    icon: Icons.family_restroom,
    sokajyValues: ['Mpanabe'],
  ),
  SokajyCategory(
    label: 'Papa / Eveka',
    icon: Icons.workspace_premium,
    sokajyValues: ['Papa', 'Eveka'],
  ),
  SokajyCategory(
    label: 'Hermita',
    icon: Icons.hiking,
    sokajyValues: ['Hermita'],
  ),
];

/// Mikaroka ny [SokajyCategory] (sy noho izany ny icon mifandraika aminy)
/// izay misy ny soatoavina "sokajy" nomena (avy amin'ny olomasina.json).
/// Mamerina null raha tsy misy sokajy mifanaraka.
SokajyCategory? findSokajyCategory(String sokajy) {
  for (final category in sokajyCategories) {
    if (category.sokajyValues.contains(sokajy)) {
      return category;
    }
  }
  return null;
}
