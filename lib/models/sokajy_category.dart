/// Mirakitra ny fifandraisan'ny sokajy Olomasina (JSON: "sokajy")
/// amin'ny sary any amin'ny assets/images/categories/, mba hamoronana
/// pejy grid azo tsindriana hisivanana Olomasina araka ny sokajiny.
class SokajyCategory {
  final String label;

  /// Anaran'ny sary ao anaty assets/images/categories/ (tsy misy lalana feno)
  final String imagePath;

  /// Ireo soatoavina "sokajy" ao amin'ny olomasina.json mifandray amin'ity
  /// sokajy ity (azo mitambatra maromaro ao anaty tile iray)
  final List<String> sokajyValues;

  const SokajyCategory({
    required this.label,
    required this.imagePath,
    required this.sokajyValues,
  });
}

const List<SokajyCategory> sokajyCategories = [
  SokajyCategory(
    label: 'Masina',
    imagePath: 'masina.png',
    sokajyValues: ['Masina Lehibe', 'Masina'],
  ),
  SokajyCategory(
    label: 'Apostoly sy Misionera',
    imagePath: 'apostoly.png',
    sokajyValues: ['Apostoly', 'Misionera'],
  ),
  SokajyCategory(
    label: 'Mpampianatra ny Fiangonana',
    imagePath: 'mpampianatry.png',
    sokajyValues: ['Mpampianatra ny Fiangonana'],
  ),
  SokajyCategory(
    label: 'Mpanorina Ordina',
    imagePath: 'mpanorina.png',
    sokajyValues: ['Mpanorina Ordina', 'Relijiozy'],
  ),
  SokajyCategory(
    label: 'Martiry',
    imagePath: 'martiry.png',
    sokajyValues: ['Martiry'],
  ),
  SokajyCategory(
    label: 'Virijiny',
    imagePath: 'virijiny.png',
    sokajyValues: ['Virijiny'],
  ),

  SokajyCategory(
    label: 'Relijiozy',
    imagePath: 'relijiozy.png',
    sokajyValues: ['Relijiozy'],
  ),
  SokajyCategory(
    label: 'Mpanabe',
    imagePath: 'mpanabe.png',
    sokajyValues: ['Mpanabe'],
  ),
  SokajyCategory(
    label: 'Papa / Eveka',
    imagePath: 'papa_eveka.png',
    sokajyValues: ['Papa', 'Eveka'],
  ),
];
