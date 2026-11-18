import '../data/app_database.dart';
import 'liturgical_calendar.dart';
import '../models/liturgical_data.dart';

/// Kilasy mpampifandray ny database (vakiteny) sy ny LiturgicalCalendar (daty/code).
///
/// Ny olana: ny code toy ny "ORDINARY_SUNDAY_12" (avy amin'ny calendar) dia tsy
/// mitovy soratra amin'ny "anarana" ao amin'ny database
/// ("Alahady faharoa ambin'ny folo amin'ny fotoana mahazatra"). Io kilasy io
/// no manova ny code ho lasa "kaody fikarohana" (vondrona + anarana malagasy)
/// mba hahitana ilay andalana mifanaraka.
///
/// Ny angona dia voahodina ao amin'ny `smc.db`. Ny "metadata" (vondrona, anarana,
/// taona, lohahevitra) ihany no voamaha mialoha ([load]); ny andininy lava
/// dia voamaha rehefa sokafana ny antsipirihany ([loadVakyTeny]).
class LiturgicalReadingsService {
  static LiturgicalSnapshot? _snapshot;
  static final Map<int, List<Reading>> _vakyCache = {};
  static const int _vakyCacheMax = 24;

  static bool get isLoaded => _snapshot != null;

  /// Alimanaka efa kajy (ao RAM) ho an'ny taona litorjika ankehitriny.
  static LiturgicalSnapshot get snapshot {
    final s = _snapshot;
    if (s == null) {
      throw StateError(
        'LiturgicalReadingsService.load() tsy mbola vita (jereo AppData.init).',
      );
    }
    return s;
  }

  /// Mamaky ny metadata, mikajy ny alimanaka ary mametraka mialoha ny
  /// vakitenin'ny "Alahady farany teo" (voalohany horesahina).
  static Future<void> load({DateTime? today}) async {
    final readings = await loadReadings();
    final snap = buildSnapshot(readings, today ?? DateTime.now());
    final lastId = snap.lastSunday?.readings?.id;
    if (lastId != null) {
      await loadVakyTeny(lastId);
    }
    _snapshot = snap;
  }

  /// Famakiana ny metadata (tsy misy andininy) avy ao amin'ny database.
  static Future<List<LiturgicalDayReadings>> loadReadings() async {
    final db = await AppDatabase.instance.open();
    final rows = await db.query('litorjika', orderBy: 'id');
    return rows
        .map(
          (r) => LiturgicalDayReadings(
            id: r['id'] as int,
            vondrona: decryptText(r['vondrona']),
            anarana: decryptText(r['anarana']),
            taona: decryptText(r['taona']),
            lohahevitra: decryptText(r['lohahevitra']),
            isaVaky: r['isa_vaky'] as int,
          ),
        )
        .toList();
  }

  /// Mamaky ny vakiteny (andininy) an'ny andro iray (ary tehirizina ao RAM).
  static Future<List<Reading>> loadVakyTeny(int litorjikaId) async {
    final cached = _vakyCache[litorjikaId];
    if (cached != null) return cached;

    final db = await AppDatabase.instance.open();
    final rows = await db.query(
      'litorjika_vaky',
      where: 'litorjika_id = ?',
      whereArgs: [litorjikaId],
      orderBy: 'ordre',
    );
    final list = List<Reading>.unmodifiable(
      rows.map(
        (r) => Reading(
          karazany: decryptText(r['karazany']),
          reference: decryptText(r['reference']),
          boky: decryptText(r['boky']),
          andininy: decryptText(r['andininy']),
        ),
      ),
    );

    if (_vakyCache.length >= _vakyCacheMax) {
      _vakyCache.remove(_vakyCache.keys.first);
    }
    _vakyCache[litorjikaId] = list;
    return list;
  }

  /// Mikajy ny daty nanombohan'ny Fiaviana (Alahady voalohany amin'ny Fiaviana)
  /// ho an'ny taona sivilizasiona iray. Ny Krismasy dia 25 Desambra foana; ny
  /// Fiaviana dia 4 Alahady alohan'ny Krismasy.
  static DateTime startOfLiturgicalYear(int civilYear) {
    final christmas = DateTime(civilYear, 12, 25);
    final daysToSubtract = (christmas.weekday % 7) + 21;
    final startAdvent = christmas.subtract(Duration(days: daysToSubtract));
    return DateTime(startAdvent.year, startAdvent.month, startAdvent.day);
  }

  /// Manivana ny andro amin'ny Taona Litorjika ankehitriny (Fiaviana -> Kristy Mpanjaka).
  static LiturgicalSnapshot buildSnapshot(
    List<LiturgicalDayReadings> allReadings,
    DateTime today,
  ) {
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Mikajy ny taon'ny litorjika telo mba hahazoana antoka fa feno ny angona
    final merged = buildCalendarSpanningYears(
      today.year - 1,
      today.year + 1,
      allReadings,
    );
    final last = findLastEventUpTo(merged, todayOnly);

    final adventThisYear = startOfLiturgicalYear(today.year);
    final DateTime currentStart = todayOnly.isBefore(adventThisYear)
        ? startOfLiturgicalYear(
            today.year - 1,
          ) // mbola ao anatin'ny taona taloha
        : adventThisYear; // efa niditra amin'ny taona litorjika vaovao
    final nextStart = startOfLiturgicalYear(currentStart.year + 1);

    final days = merged.where((event) {
      final d = DateTime(event.date.year, event.date.month, event.date.day);
      return !d.isBefore(currentStart) && d.isBefore(nextStart);
    }).toList();

    return LiturgicalSnapshot(days: List.unmodifiable(days), lastSunday: last);
  }

  // ---------------------------------------------------------------------
  // Fanovana isa (2..33) ho teny malagasy, araka ny endrika ampiasain'ny
  // JSON ("faharoa", "fahatelo", ... "fahiraika ambin'ny folo", ...)
  // ---------------------------------------------------------------------
  static const List<String> _units = [
    '', // 0 (tsy ampiasaina)
    'fahiraika',
    'faharoa',
    'fahatelo',
    'fahefatra',
    'fahadimy',
    'fahenina',
    'fahafito',
    'fahavalo',
    'fahasivy',
  ];

  static String _ordinaryOrdinal(int n) {
    if (n <= 10) {
      const map = {
        2: 'faharoa',
        3: 'fahatelo',
        4: 'fahefatra',
        5: 'fahadimy',
        6: 'fahenina',
        7: 'fahafito',
        8: 'fahavalo',
        9: 'fahasivy',
        10: 'fahafolo',
      };
      return map[n] ?? '';
    } else if (n < 20) {
      return "${_units[n - 10]} ambin'ny folo";
    } else if (n == 20) {
      return 'faharoa-polo';
    } else if (n < 30) {
      return '${_units[n - 20]} amby roapolo';
    } else if (n == 30) {
      return 'fahatelopolo';
    } else {
      return '${_units[n - 30]} amby telopolo';
    }
  }

  // Anarana manokana ho an'ny Advento / Karemy / Paka (tsy manaraka ny
  // lamina ambony satria samy hafa ny fomba fanoratana azy ao amin'ny JSON).
  static const Map<int, String> _adventNames = {
    1: "Alahady voalohan'ny Fiaviana",
    2: "Alahady faharoan'ny Fiaviana",
    3: "Alahady fahatelon'ny Fiaviana",
    4: "Alahady fahefatry ny Fiaviana",
  };

  static const Map<int, String> _lentNames = {
    1: "Alahady voalohan'ny Karemy",
    2: "Alahady faharoan'ny Karemy",
    3: "Alahady fahatelon'ny Karemy",
    4: "Alahady fahefatry ny Karemy",
    5: "Alahady fahadimin'ny Karemy",
  };

  static const Map<int, String> _easterNames = {
    2: "Alahady faharoan'ny Paka (Famindram-po Andriamanitra)",
    3: "Alahady fahatelon'ny Paka",
    4: "Alahady fahefatry ny Paka (Mpiandry Tsara)",
    5: "Alahady fahadimin'ny Paka",
    6: "Alahady fahenin'ny Paka",
    7: "Alahady fahafiton'ny Paka",
  };

  /// Mamaha ny (vondrona, anarana) tokony hokarohina ao amin'ny JSON,
  /// araka ny "code" navoakan'ny LiturgicalCalendar.
  /// Mamerina null raha tsy misy antokony mifanandrify (oh: ASH_WEDNESDAY).
  static (String vondrona, String anarana)? _searchKeyFor(String code) {
    if (code.startsWith('ORDINARY_SUNDAY_')) {
      final n = int.parse(code.substring('ORDINARY_SUNDAY_'.length));
      if (n == 34) {
        return (
          'Fetim-panjakana',
          "I Kristy Mpanjaka: Alahady farany amin'ny fotoana mahazatra",
        );
      }
      return (
        'Fotoana mahazatra',
        "Alahady ${_ordinaryOrdinal(n)} amin'ny fotoana mahazatra",
      );
    }
    if (code.startsWith('ADVENT_')) {
      final n = int.parse(code.substring('ADVENT_'.length));
      return ('Fiaviana', _adventNames[n]!);
    }
    if (code.startsWith('LENT_SUNDAY_')) {
      final n = int.parse(code.substring('LENT_SUNDAY_'.length));
      return ('Karemy', _lentNames[n]!);
    }
    if (code == 'PALM_SUNDAY') {
      return (
        'Karemy',
        "Alahadin'ny Sampan-drofia sy ny Fijalian'ny Tompo (Lamesa)",
      );
    }
    if (code == 'EASTER') {
      return (
        'Paka',
        "Alahadin'ny Paka: Ny Fitsanganan'ny Tompo tamin'ny Maty",
      );
    }
    if (code.startsWith('EASTER_SUNDAY_')) {
      final n = int.parse(code.substring('EASTER_SUNDAY_'.length));
      final name = _easterNames[n];
      if (name == null) return null;
      return ('Paka', name);
    }
    if (code == 'SACRED_HEART_OF_JESUS') {
      return ('Fetim-panjakana', "Ny Fo Masin'i Jesoa");
    }
    if (code == 'PENTECOST') {
      return ('Paka', "Pentekosta: Amin'ny antoandro");
    }
    if (code == 'ASCENSION') {
      return ('Paka', "Ny Fiakaran'ny Tompo");
    }
    if (code == 'TRINITY_SUNDAY') {
      return ('Fetim-panjakana', 'Ny Trinite Masina');
    }
    if (code == 'CORPUS_CHRISTI') {
      return ('Fetim-panjakana', "Ny Vatana sy Ran'ny Kristy");
    }
    if (code == 'BAPTISM_OF_LORD') {
      return ('Krismasy', 'Ny Batemin\'ny Tompo');
    }
    if (code == 'CHRISTMAS') {
      return ('Krismasy', "Krismasy: Amin'ny antoandro");
    }
    if (code == 'HOLY_FAMILY') {
      return ('Krismasy', "Ny Fianakaviana Masina");
    }
    if (code == 'MARY_MOTHER_OF_GOD') {
      // Daty raikitra (1 Janoary), koa "ABC" no soratana ho an'ny "taona".
      return ('Krismasy', "Maria Reny Masin'Andriamanitra");
    }
    if (code == 'ASH_WEDNESDAY') {
      // Mitovy vakiteny isan-taona (A, B, C) ny an'ny Alarobian'ny Lavenona,
      // koa "ABC" no soratana ao amin'ny JSON ho an'ny "taona" mifanaraka.
      return ('Karemy', "Alarobian'ny Lavenona");
    }
    return null;
  }

  /// Karohina ao amin'ny lisitry ny JSON ilay andalana mifanaraka amin'ny
  /// (vondrona, anarana) sy ny taona (cycle A/B/C). Ny taona "ABC" ao amin'ny
  /// JSON dia midika hoe tsy miova na inona na inona taona.
  static LiturgicalDayReadings? _findMatch(
    List<LiturgicalDayReadings> allReadings,
    String vondrona,
    String anarana,
    String cycle,
  ) {
    for (final r in allReadings) {
      if (r.vondrona == vondrona &&
          r.anarana == anarana &&
          (r.taona == cycle || r.taona == 'ABC')) {
        return r;
      }
    }
    return null;
  }

  /// Ny fototry ny fampifandraisana: mamokatra ny lisitry ny
  /// [MergedLiturgicalDay] ho an'ny taona iray, miaraka amin'ny vakiteny
  /// (raha nahitana) avy amin'ny JSON.
  static List<MergedLiturgicalDay> buildCalendarForYear(
    int year,
    List<LiturgicalDayReadings> allReadings,
  ) {
    final String cycle = LiturgicalCalendar.getCycle(year);
    final events = LiturgicalCalendar.getEventsForYear(year);

    return events.map((event) {
      final key = _searchKeyFor(event.code);
      LiturgicalDayReadings? match;
      if (key != null) {
        match = _findMatch(allReadings, key.$1, key.$2, cycle);
      }
      return MergedLiturgicalDay(
        code: event.code,
        title: event.title,
        date: event.date,
        readings: match,
      );
    }).toList();
  }

  /// Mamokatra ny lisitra manontolo, mitohy avy amin'ny taona iray ka hatramin'ny
  /// manaraka azy (mba tsy hisy "banga" manodidina ny Krismasy/Advento).
  static List<MergedLiturgicalDay> buildCalendarSpanningYears(
    int fromYear,
    int toYear,
    List<LiturgicalDayReadings> allReadings,
  ) {
    final List<MergedLiturgicalDay> all = [];
    for (int y = fromYear; y <= toYear; y++) {
      all.addAll(buildCalendarForYear(y, allReadings));
    }
    all.sort((a, b) => a.date.compareTo(b.date));
    return all;
  }

  /// Mitady ny "Alahady farany teo" (ny fisehoan-javatra farany navakiana,
  /// izany hoe ny daty farany <= androany).
  static MergedLiturgicalDay? findLastEventUpTo(
    List<MergedLiturgicalDay> sortedEvents,
    DateTime today,
  ) {
    MergedLiturgicalDay? last;
    for (final e in sortedEvents) {
      if (!e.date.isAfter(DateTime(today.year, today.month, today.day))) {
        last = e;
      } else {
        break;
      }
    }
    return last;
  }
}
