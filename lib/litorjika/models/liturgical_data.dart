/// Kilasy mitahiry ny vakiteny tsirairay (vakiteny 1, salamo, vakiteny 2, filazantsara)
class Reading {
  final String karazany; // oh: "Vakiteny voalohany", "Filazantsara"
  final String reference; // oh: "Isa 2:1-5"
  final String boky; // oh: "Izaia"
  final String andininy; // ny votoatin'ny andininy

  Reading({
    required this.karazany,
    required this.reference,
    required this.boky,
    required this.andininy,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      karazany: json['karazany'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      boky: json['boky'] as String? ?? '',
      andininy: json['andininy'] as String? ?? '',
    );
  }
}

/// Kilasy mitahiry ny "iray andalana" ao amin'ny JSON: vondrona, anarana, taona
/// ary ny lisitry ny vakiteny mifandraika aminy.
class LiturgicalDayReadings {
  final String vondrona; // oh: "Advento", "Fotoana mahazatra", ...
  final String anarana; // ny anarana amin'ny teny malagasy, araka ny JSON
  final String taona; // "A", "B", "C" na "ABC" raha tsy miova isan-taona
  final List<Reading> vakyTeny;

  LiturgicalDayReadings({
    required this.vondrona,
    required this.anarana,
    required this.taona,
    required this.vakyTeny,
  });

  factory LiturgicalDayReadings.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['vaky_teny'] as List<dynamic>? ?? [];
    return LiturgicalDayReadings(
      vondrona: json['vondrona'] as String? ?? '',
      anarana: json['anarana'] as String? ?? '',
      taona: json['taona'] as String? ?? '',
      vakyTeny: list
          .map((e) => Reading.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Ny vokatra farany: fisehoan-javatra litorjika iray (avy amin'ny LiturgicalCalendar)
/// izay efa nampifandraisina tamin'ny vakiteniny (avy amin'ny JSON), raha nisy.
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

  bool get hasReadings => readings != null && readings!.vakyTeny.isNotEmpty;
}
