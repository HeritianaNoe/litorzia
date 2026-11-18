import '../data/app_database.dart';
import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';

/// Service ho an'ny Olomasina avy ao amin'ny `smc.db` (angona voahodina).
///
/// Voamaha (decrypt) indray mandeha rehefa manomboka ny app ([load]) ary tahiry
/// ao RAM: ny fikarohana sy ny sivana dia SYNCHRONE (tsy misy `await`), ka tsy
/// mila spinner ny pejy ary tsy mitsambikina rehefa mitaipa na miova pejy.
class OlomasinaService {
  OlomasinaService._();
  static final OlomasinaService instance = OlomasinaService._();

  List<Olomasina> _rehetra = const [];

  /// Soratra kely (lowercase) ho an'ny fikarohana: anarana, sokajy, fanoharana.
  List<String> _index = const [];
  Map<String, int> _isaAminSokajy = const {};
  final Map<String, List<Olomasina>> _cacheSokajy = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final db = await AppDatabase.instance.open();
    final rows = await db.query('olomasina');

    final list = rows.map(_avyAminNyRow).toList()
      // Mandahatra azy araka ny anarana (A-Z)
      ..sort((a, b) => a.anarana.compareTo(b.anarana));

    final isa = <String, int>{};
    for (final o in list) {
      isa[o.sokajy] = (isa[o.sokajy] ?? 0) + 1;
    }

    _rehetra = List.unmodifiable(list);
    _index = List.unmodifiable(
      list.map(
        (o) =>
            '${o.anarana}\u0001${o.sokajy}\u0001${o.fanoharana}'.toLowerCase(),
      ),
    );
    _isaAminSokajy = Map.unmodifiable(isa);
    _cacheSokajy.clear();
    _loaded = true;
  }

  static Olomasina _avyAminNyRow(Map<String, Object?> row) {
    return Olomasina(
      id: row['id'] as int?,
      anarana: decryptText(row['anarana']),
      datyFankalazana: decryptText(row['daty_fankalazana']),
      sary: decryptNullable(row['sary']),
      fanoharana: decryptText(row['fanoharana']),
      tantara: decryptText(row['tantara']),
      sokajy: decryptText(row['sokajy']),
      taonaNahaterahana: decryptNullable(row['taona_nahaterahana']),
      taonaNahafatesana: decryptNullable(row['taona_nahafatesana']),
    );
  }

  void _ensureLoaded() {
    if (!_loaded) {
      throw StateError(
        'OlomasinaService.load() tsy mbola vita (jereo AppData.init).',
      );
    }
  }

  /// Olomasina rehetra (voasokajy A-Z).
  List<Olomasina> get rehetra {
    _ensureLoaded();
    return _rehetra;
  }

  /// Mikaroka Olomasina araka ny teny voasoratra (anarana, sokajy, na fanoharana).
  List<Olomasina> karohy(String teny) {
    final query = teny.trim().toLowerCase();
    if (query.isEmpty) return rehetra;

    final result = <Olomasina>[];
    for (var i = 0; i < _rehetra.length; i++) {
      if (_index[i].contains(query)) result.add(_rehetra[i]);
    }
    return result;
  }

  /// Isan'ny Olomasina ao amin'ny sokajy (ahitana ny soatoavina rehetra mifandray aminy).
  int isaAmin(SokajyCategory category) {
    _ensureLoaded();
    var total = 0;
    for (final v in category.sokajyValues) {
      total += _isaAminSokajy[v] ?? 0;
    }
    return total;
  }

  /// Olomasina ao amin'ny sokajy (tahiry ao RAM, tsy averina kajiana).
  List<Olomasina> olomasinaAmin(SokajyCategory category) {
    return _cacheSokajy.putIfAbsent(
      category.label,
      () => List.unmodifiable(
        rehetra.where((o) => category.sokajyValues.contains(o.sokajy)),
      ),
    );
  }

  /// Olomasina fankalazaina amin'ny andro voatondro (androany raha tsy misy 'andro').
  /// Mety hisy Olomasina maromaro mizara daty iray ihany, ka lisitra no averina.
  List<Olomasina> androany({DateTime? andro}) {
    final DateTime izao = andro ?? DateTime.now();
    return rehetra.where((o) => _mifanaraka(o.datyFankalazana, izao)).toList();
  }

  /// Ireo anaran-bolana Malagasy ekena ho mifanandrify amin'ny isan-bolana
  /// (1 = Janoary, ... 12 = Desambra). Nampidirina ny endriny samihafa hita
  /// tao amin'ny angona (oh: "Marsa"/"Martsa", "Novambra"/"Nôvambra")
  /// mba tsy hisy tsy fetezana amin'ny fampitahana.
  static const Map<int, List<String>> _anaranVolanaEkena = {
    1: ['janoary'],
    2: ['febroary'],
    3: ['marsa', 'martsa'],
    4: ['aprily'],
    5: ['mey'],
    6: ['jona'],
    7: ['jolay'],
    8: ['aogositra'],
    9: ['septambra'],
    10: ['oktobra'],
    11: ['novambra'],
    12: ['desambra'],
  };

  /// Anaran-bolana Malagasy ho an'ny fampisehoana (endrika iraisana indrindra
  /// tao amin'ny angona).
  static const List<String> anaranVolanaFampisehoana = [
    'Janoary',
    'Febroary',
    'Martsa',
    'Aprily',
    'Mey',
    'Jona',
    'Jolay',
    'Aogositra',
    'Septambra',
    'Oktobra',
    'Novambra',
    'Desambra',
  ];

  /// Mamerina ny daty amin'ny endriny "DD Volana" (oh: "27 Aogositra")
  /// mifanaraka amin'ny endriky ny "daty_fankalazana".
  static String formatoDaty(DateTime andro) {
    final String volana = anaranVolanaFampisehoana[andro.month - 1];
    return '${andro.day.toString().padLeft(2, '0')} $volana';
  }

  static String _manalaDiakritika(String teny) =>
      teny.toLowerCase().trim().replaceAll('ô', 'o');

  /// 'true' raha mifanandrify amin'ny 'andro' voatondro ny 'datyFankalazana'
  /// iray (mitovy ny isan'andro sy ny volana, tsy miraharaha ny endri-tsoratra).
  bool _mifanaraka(String datyFankalazana, DateTime andro) {
    final List<String> ampahany = datyFankalazana.trim().split(RegExp(r'\s+'));
    if (ampahany.length < 2) return false;

    final int? isanAndro = int.tryParse(ampahany.first);
    if (isanAndro == null || isanAndro != andro.day) return false;

    final String volanaVoasoratra = _manalaDiakritika(
      ampahany.sublist(1).join(' '),
    );
    final List<String>? volanaEkena = _anaranVolanaEkena[andro.month];

    return volanaEkena != null && volanaEkena.contains(volanaVoasoratra);
  }
}
