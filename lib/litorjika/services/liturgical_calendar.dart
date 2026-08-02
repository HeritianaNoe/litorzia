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

  /// Kajy ny Alahady voalohan'ny Advento
  static DateTime getFirstSundayOfAdvent(int year) {
    DateTime christmas = DateTime(year, 12, 25);
    int christmasWeekday = christmas.weekday;
    int daysToFirstSunday = 21 + (christmasWeekday % 7);
    return christmas.subtract(Duration(days: daysToFirstSunday));
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
      title: 'Bateminy ny Tompo (Famaranana ny Krismasy)',
      date: baptism,
    ));

    // Ny Alahady 2 Mandavantaona dia ny Alahady manaraka ny Batemy
    DateTime currentSunday = baptism.add(const Duration(days: 7));
    int ordNumber = 2;

    while (currentSunday.isBefore(ashWednesday)) {
      events.add(LiturgicalEvent(
        code: 'ORDINARY_SUNDAY_$ordNumber',
        title: 'Alahady faha-$ordNumber Mandavantaona',
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
        title: 'Alahady faha-$i amin\'ny Karemy',
        date: ashWednesday.add(Duration(days: 4 + (i - 1) * 7)),
      ));
    }

    events.add(LiturgicalEvent(
      code: 'PALM_SUNDAY',
      title: 'Alahadyn\'ny Sampan-kazo',
      date: easter.subtract(const Duration(days: 7)),
    ));

    events.add(LiturgicalEvent(
      code: 'EASTER',
      title: 'Andro Masina Paka',
      date: easter,
    ));

    for (int i = 2; i <= 7; i++) {
      events.add(LiturgicalEvent(
        code: 'EASTER_SUNDAY_$i',
        title: 'Alahady faha-$i amin\'ny Paka',
        date: easter.add(Duration(days: (i - 1) * 7)),
      ));
    }

    events.add(LiturgicalEvent(
      code: 'PENTECOST',
      title: 'Pentekosta',
      date: pentecost,
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
      title: 'Vatsin\'ny Mpahazo (Corpus Christi)',
      date: easter.add(const Duration(days: 63)), // Mankalaza amin'ny Alahady
    ));

    // Miverina amin'ny Mandavantaona ny Alahady aorian'ny Pentekosta
    // Ny isa manaraka dia mikajy mba ho ny Alahady faha-34 no farany mialoha ny Advento
    DateTime lastOrdinarySunday = advent1.subtract(const Duration(days: 7));
    currentSunday = pentecost.add(const Duration(days: 7));
    
    // Mampifanaraka ny laharana Mandavantaona (Matetika faha-8 hatramin'ny faha-34)
    int postPentecostOrdNumber = 34 - (lastOrdinarySunday.difference(currentSunday).inDays ~/ 7);

    while (currentSunday.isBefore(advent1)) {
      // Tsy soloina ny Alahady Trinite sy Corpus Christi raha mifanOverlap
      String title = (postPentecostOrdNumber == 34) 
          ? 'Alahady faha-34 Mandavantaona (Kristy Mpanjaka)' 
          : 'Alahady faha-$postPentecostOrdNumber Mandavantaona';

      events.add(LiturgicalEvent(
        code: 'ORDINARY_SUNDAY_$postPentecostOrdNumber',
        title: title,
        date: currentSunday,
      ));

      postPentecostOrdNumber++;
      currentSunday = currentSunday.add(const Duration(days: 7));
    }

    // -------------------------------------------------------------
    // 4. ADVENTO SY KRISMASY
    // -------------------------------------------------------------
    events.add(LiturgicalEvent(
      code: 'ADVENT_1',
      title: 'Alahady 1 amin\'ny Advento',
      date: advent1,
    ));
    events.add(LiturgicalEvent(
      code: 'ADVENT_2',
      title: 'Alahady 2 amin\'ny Advento',
      date: advent1.add(const Duration(days: 7)),
    ));
    events.add(LiturgicalEvent(
      code: 'ADVENT_3',
      title: 'Alahady 3 amin\'ny Advento (Gaudete)',
      date: advent1.add(const Duration(days: 14)),
    ));
    events.add(LiturgicalEvent(
      code: 'ADVENT_4',
      title: 'Alahady 4 amin\'ny Advento',
      date: advent1.add(const Duration(days: 21)),
    ));

    events.add(LiturgicalEvent(
      code: 'CHRISTMAS',
      title: 'Fahatsiarovana ny Hena Masina (Krismasy)',
      date: DateTime(year, 12, 25),
    ));

    // Sordina araka ny filaharan'ny daty
    events.sort((a, b) => a.date.compareTo(b.date));

    return events;
  }
}
