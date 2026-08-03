import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'liturgical_calendar.dart';
import '../models/liturgical_data.dart';

/// Kilasy mpampifandray ny JSON (vakiteny) sy ny LiturgicalCalendar (daty/code).
///
/// Ny olana: ny code toy ny "ORDINARY_SUNDAY_12" (avy amin'ny calendar) dia tsy
/// mitovy soratra amin'ny "anarana" ao amin'ny JSON
/// ("Alahady faharoa ambin'ny folo amin'ny fotoana mahazatra"). Io kilasy io
/// no manova ny code ho lasa "kaody fikarohana" (vondrona + anarana malagasy)
/// mba hahitana ilay andalana mifanaraka ao amin'ny JSON.
class LiturgicalReadingsService {
  /// Famakiana ny rakitra JSON avy ao amin'ny assets
  static Future<List<LiturgicalDayReadings>> loadReadings() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/litorjika.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((e) => LiturgicalDayReadings.fromJson(e as Map<String, dynamic>))
        .toList();
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
      return ('Fotoana mahazatra', "Alahady ${_ordinaryOrdinal(n)} amin'ny fotoana mahazatra");
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
      return ('Karemy', "Alahadin'ny Sampan-drofia sy ny Fijalian'ny Tompo (Lamesa)");
    }
    if (code == 'EASTER') {
      return ('Paka', "Alahadin'ny Paka: Ny Fitsanganan'ny Tompo tamin'ny Maty");
    }
    if (code.startsWith('EASTER_SUNDAY_')) {
      final n = int.parse(code.substring('EASTER_SUNDAY_'.length));
      final name = _easterNames[n];
      if (name == null) return null;
      return ('Paka', name);
    }
    if (code == 'PENTECOST') {
      return ('Paka', "Pentekosta: Amin'ny antoandro");
    }
    if (code == 'TRINITY_SUNDAY') {
      return ('Fetim-panjakana', 'Ny Trinite Masina');
    }
    if (code == 'CORPUS_CHRISTI') {
      return ('Fetim-panjakana', "Ny Vatana sy Ran'ny Kristy (Korpus Kristi)");
    }
    if (code == 'BAPTISM_OF_LORD') {
      return ('Krismasy', 'Ny Batemin\'ny Tompo');
    }
    if (code == 'CHRISTMAS') {
      return ('Krismasy', "Krismasy: Amin'ny antoandro");
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
