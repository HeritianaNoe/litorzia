/// Kilasy anehoana ny fisehoan-javatra litorjika (Liturgical Event)
class LiturgicalEvent {
  final String code;       // Kaody famantarana (oh: ORDINARY_SUNDAY_1, EASTER, etc.)
  final String title;      // Anaran'ny fety na alahady (amin'ny teny malagasy)
  final DateTime date;     // Datin'ilay fety

  LiturgicalEvent({
    required this.code,
    required this.title,
    required this.date,
  });

  @override
  String toString() => '$code | $title : ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Kilasy mikajy ny daty litorjika rehetra mandritra ny taona
class LiturgicalCalendar {
  
  /// Kajy ny Tsingerin-taona Litorjika (Taona A, B, na C)
  static String getCycle(int year) {
    int mod = year % 3;
    if (mod == 1) return 'A';
    if (mod == 2) return 'B';
    return 'C';
  }

  /// Kajy ny datin'ny Paka (Algorithm Anonymous Gregorian)
  static DateTime getEaster(int year) {
    int a = year % 19;
    int b = year ~/ 100;
    int c = year % 100;
    int d = b ~/ 4;
    int e = b % 4;
    int f = (b + 8) ~/ 25;
    int g = (b - f + 1) ~/ 3;
    int h = (19 * a + b - d - g + 15) % 30;
    int i = c ~/ 4;
    int k = c % 4;
    int l = (32 + 2 * e + 2 * i - h - k) % 7;
    int m = (a + 11 * h + 22 * l) ~/ 451;
    
    int month = (h + l - 7 * m + 114) ~/ 31;
    int day = ((h + l - 7 * m + 114) % 31) + 1;

    return DateTime(year, month, day);
  }

  /// Kajy ny Epifania (Ny Alahady voalohany aorian'ny 1 Janoary na 6 Janoary)
  static DateTime getEpiphany(int year) {
    DateTime jan1 = DateTime(year, 1, 1);
    int daysUntilSunday = (DateTime.sunday - jan1.weekday + 7) % 7;
    if (daysUntilSunday == 0) daysUntilSunday = 7; // Raha Alahady ny 1 Janoary
    return jan1.add(Duration(days: daysUntilSunday));
  }

  /// Kajy ny Batemin'ny Tompo (Alahady aorian'ny Epifania)
  static DateTime getBaptismOfLord(int year) {
    return getEpiphany(year).add(const Duration(days: 7));
  }

  /// Kajy ny Alahady voalohan'ny Fiaviana
  static DateTime getFirstSundayOfAdvent(int year) {
    DateTime christmas = DateTime(year, 12, 25);
    int christmasWeekday = christmas.weekday;
    int daysToFirstSunday = 21 + (christmasWeekday % 7);
    return christmas.subtract(Duration(days: daysToFirstSunday));
  }

  /// Kajy ny Fetin'ny Fianakavian'i Nazareta Masina: ny Alahady eo anelanelan'
  /// ny 26 sy 31 Desambra (ao anatin'ny Oktavan'ny Noely); raha tsy misy
  /// Alahady amin'io fe-potoana io (satria Alahady mihitsy ny 25 Desambra),
  /// dia ny 30 Desambra no ankalazana azy.
  static DateTime getHolyFamily(int year) {
    for (int day = 26; day <= 31; day++) {
      DateTime d = DateTime(year, 12, day);
      if (d.weekday == DateTime.sunday) return d;
    }
    return DateTime(year, 12, 30);
  }

  /// MAZO NY LISITRA REHETRA (Ahitana ireo Alahady Mandavantaona rehetra)
  static List<LiturgicalEvent> getEventsForYear(int year) {
    List<LiturgicalEvent> events = [];

    DateTime easter = getEaster(year);
    DateTime ashWednesday = easter.subtract(const Duration(days: 46));
    DateTime pentecost = easter.add(const Duration(days: 49));
    DateTime advent1 = getFirstSundayOfAdvent(year);

    // -------------------------------------------------------------
    // 1. ANTSO MANDAVANTAONA PAROASY I (Mialoha ny Karemy)
    // -------------------------------------------------------------
    DateTime baptism = getBaptismOfLord(year);
    events.add(LiturgicalEvent(
      code: 'BAPTISM_OF_LORD',
      title: 'Bateminy ny Tompo',
      date: baptism,
    ));

    // Ny Alahady 2 Mandavantaona dia ny Alahady manaraka ny Batemy
    DateTime currentSunday = baptism.add(const Duration(days: 7));
    int ordNumber = 2;

    while (currentSunday.isBefore(ashWednesday)) {
      events.add(LiturgicalEvent(
        code: 'ORDINARY_SUNDAY_$ordNumber',
        title: 'Alahady faha-$ordNumber Tsotra',
        date: currentSunday,
      ));
      ordNumber++;
      currentSunday = currentSunday.add(const Duration(days: 7));
    }

    // -------------------------------------------------------------
    // 2. KAREMY SY PAKA (Temps du Carême et de Pâques)
    // -------------------------------------------------------------
    events.add(LiturgicalEvent(
      code: 'ASH_WEDNESDAY',
      title: 'Alarobian\'ny Lavenona',
      date: ashWednesday,
    ));

    for (int i = 1; i <= 5; i++) {
      events.add(LiturgicalEvent(
        code: 'LENT_SUNDAY_$i',
        title: 'Alahady faha-$i Karemy',
        date: ashWednesday.add(Duration(days: 4 + (i - 1) * 7)),
      ));
    }

    events.add(LiturgicalEvent(
      code: 'PALM_SUNDAY',
      title: 'Alahady ny Sampan-kazo',
      date: easter.subtract(const Duration(days: 7)),
    ));

    events.add(LiturgicalEvent(
      code: 'EASTER',
      title: 'Alahady Paka',
      date: easter,
    ));

    for (int i = 2; i <= 7; i++) {
      events.add(LiturgicalEvent(
        code: 'EASTER_SUNDAY_$i',
        title: 'Alahady faha-$i Paka',
        date: easter.add(Duration(days: (i - 1) * 7)),
      ));
    }

    events.add(LiturgicalEvent(
      code: 'PENTECOST',
      title: 'Alahady Pentekoty',
      date: pentecost,
    ));

    events.add(LiturgicalEvent(
      code: 'SACRED_HEART_OF_JESUS',
      title: 'Ny Fo Masin\'i Jesoa',
      date: pentecost.add(Duration(days: 19)),
    ));

    events.add(LiturgicalEvent(
      code: 'ASCENSION',
      title: 'Ny Fiakaran\'ny Tompo',
      date: pentecost.subtract(Duration(days: 10)),
    ));

    // -------------------------------------------------------------
    // 3. ANTSO MANDAVANTAONA PAROASY II (Aorian'ny Pentekosta)
    // -------------------------------------------------------------
    events.add(LiturgicalEvent(
      code: 'TRINITY_SUNDAY',
      title: 'Alahady Trinite Masina',
      date: easter.add(const Duration(days: 56)),
    ));

    events.add(LiturgicalEvent(
      code: 'CORPUS_CHRISTI',
      title: 'Ny Vatana sy Ran\'ny Kristy',
      date: easter.add(const Duration(days: 63)), // Mankalaza amin'ny Alahady
    ));

    // Miverina amin'ny Mandavantaona ny Alahady aorian'ny Pentekosta
    // Ny isa manaraka dia mikajy mba ho ny Alahady faha-34 no farany mialoha ny Fiaviana
    DateTime lastOrdinarySunday = advent1.subtract(const Duration(days: 7));
    currentSunday = pentecost.add(const Duration(days: 7));
    
    // Mampifanaraka ny laharana Mandavantaona (Matetika faha-8 hatramin'ny faha-34)
    int postPentecostOrdNumber = 34 - (lastOrdinarySunday.difference(currentSunday).inDays ~/ 7);

    while (currentSunday.isBefore(advent1)) {
      // Tsy soloina ny Alahady Trinite sy Corpus Christi raha mifanOverlap
      String title = (postPentecostOrdNumber == 34) 
          ? 'Alahady faha-34 Tsotra (Kristy Mpanjaka)' 
          : 'Alahady faha-$postPentecostOrdNumber Tsotra';

      events.add(LiturgicalEvent(
        code: 'ORDINARY_SUNDAY_$postPentecostOrdNumber',
        title: title,
        date: currentSunday,
      ));

      postPentecostOrdNumber++;
      currentSunday = currentSunday.add(const Duration(days: 7));
    }

    // -------------------------------------------------------------
    // 4. Fiaviana SY KRISMASY
    // -------------------------------------------------------------
    events.add(LiturgicalEvent(
      code: 'ADVENT_1',
      title: 'Alahady voalohany Fiaviana',
      date: advent1,
    ));
    events.add(LiturgicalEvent(
      code: 'ADVENT_2',
      title: 'Alahady faha-2 Fiaviana',
      date: advent1.add(const Duration(days: 7)),
    ));
    events.add(LiturgicalEvent(
      code: 'ADVENT_3',
      title: 'Alahady faha-3 Fiaviana',
      date: advent1.add(const Duration(days: 14)),
    ));
    events.add(LiturgicalEvent(
      code: 'ADVENT_4',
      title: 'Alahady faha-4 Fiaviana',
      date: advent1.add(const Duration(days: 21)),
    ));

    events.add(LiturgicalEvent(
      code: 'CHRISTMAS',
      title: 'Noely (Krismasy)',
      date: DateTime(year, 12, 25),
    ));

    // Ny Fianakavian'i Nazareta Masina (Alahady ao anatin'ny Oktavan'ny Noely)
    events.add(LiturgicalEvent(
      code: 'HOLY_FAMILY',
      title: "Ny Fianakaviana Masina",
      date: getHolyFamily(year),
    ));

    // 1 Janoary: Masiba lehiben'i Maria Reny Masin'Andriamanitra (daty raikitra)
    events.add(LiturgicalEvent(
      code: 'MARY_MOTHER_OF_GOD',
      title: "Maria Reny Masin'Andriamanitra",
      date: DateTime(year, 1, 1),
    ));

    // Sordina araka ny filaharan'ny daty
    events.sort((a, b) => a.date.compareTo(b.date));

    return events;
  }
}
