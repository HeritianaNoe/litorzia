/// Kilasy mitahiry ny vakiteny tsirairay (vakiteny 1, salamo, vakiteny 2, filazantsara)
class Reading {
  final String karazany; // oh: "Vakiteny voalohany", "Filazantsara"
  final String reference; // oh: "Isa 2:1-5"
  final String boky; // oh: "Izaia"
  final String andininy; // ny votoatin'ny andininy

  const Reading({
    required this.karazany,
    required this.reference,
    required this.boky,
    required this.andininy,
  });
}

/// Kilasy mitahiry ny "iray andalana" ao amin'ny database: vondrona, anarana,
/// taona ary ny isan'ny vakiteny mifandraika aminy.
///
/// Ny vakiteny mihitsy (andininy lava) dia TSY voamaha mialoha: alaina
/// ho an'ny fisehoan-javatra iray rehefa sokafana ny antsipiriany
/// (jereo `LiturgicalReadingsService.loadVakyTeny`).
class LiturgicalDayReadings {
  final int id; // `litorjika.id` ao amin'ny database
  final String vondrona; // oh: "Advento", "Fotoana mahazatra", ...
  final String anarana; // ny anarana amin'ny teny malagasy
  final String taona; // "A", "B", "C" na "ABC" raha tsy miova isan-taona
  final String lohahevitra;
  final int isaVaky; // isan'ny vakiteny

  const LiturgicalDayReadings({
    required this.id,
    required this.vondrona,
    required this.anarana,
    required this.taona,
    required this.lohahevitra,
    required this.isaVaky,
  });
}

/// Ny vokatra farany: fisehoan-javatra litorjika iray (avy amin'ny LiturgicalCalendar)
/// izay efa nampifandraisina tamin'ny vakiteniny (avy amin'ny database), raha nisy.
class MergedLiturgicalDay {
  final String code; // oh: "ORDINARY_SUNDAY_12"
  final String title; // ny lohateny kajian'ny calendar (malagasy ihany koa)
  final DateTime date;
  final LiturgicalDayReadings? readings; // null raha tsy nahitana valiny mitovy

  MergedLiturgicalDay({
    required this.code,
    required this.title,
    required this.date,
    this.readings,
  });

  bool get hasReadings => readings != null && readings!.isaVaky > 0;
}

/// Sary an'ny alimanaka ho an'ny taona litorjika ankehitriny (kajy mialoha).
class LiturgicalSnapshot {
  final List<MergedLiturgicalDay> days;
  final MergedLiturgicalDay? lastSunday; // "Alahady farany teo"

  const LiturgicalSnapshot({required this.days, required this.lastSunday});
}
