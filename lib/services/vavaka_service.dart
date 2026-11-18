import '../data/app_database.dart';
import '../models/vavaka_model.dart';

/// Vavaka avy ao amin'ny `smc.db` (voamaha indray mandeha, tahiry ao RAM).
class VavakaService {
  VavakaService._();
  static final VavakaService instance = VavakaService._();

  List<VavakaModel> _rehetra = const [];
  List<String> _kategoria = const ['Rehetra'];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final db = await AppDatabase.instance.open();
    final rows = await db.query('vavaka', orderBy: 'ordre');

    final list = rows
        .map(
          (r) => VavakaModel(
            id: r['id']?.toString() ?? '',
            titre: decryptText(r['titre']),
            kategoria: decryptNullable(r['kategoria']) ?? 'Tsy misy sokajy',
            teksta: decryptText(r['teksta']),
          ),
        )
        .toList();

    final categories = <String>{'Rehetra'};
    for (final item in list) {
      if (item.kategoria.isNotEmpty) categories.add(item.kategoria);
    }

    _rehetra = List.unmodifiable(list);
    _kategoria = List.unmodifiable(categories);
    _loaded = true;
  }

  void _ensureLoaded() {
    if (!_loaded) {
      throw StateError(
        'VavakaService.load() tsy mbola vita (jereo AppData.init).',
      );
    }
  }

  List<VavakaModel> get rehetra {
    _ensureLoaded();
    return _rehetra;
  }

  List<String> get kategoria {
    _ensureLoaded();
    return _kategoria;
  }
}
