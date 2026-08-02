class Olomasina {
  final int? id;
  final String anarana;
  final String datyFankalazana;
  final String? sary;
  final String fanoharana;
  final String tantara;
  final String sokajy;
  final String? taonaNahaterahana;
  final String? taonaNahafatesana;

  Olomasina({
    this.id,
    required this.anarana,
    required this.datyFankalazana,
    this.sary,
    required this.fanoharana,
    required this.tantara,
    required this.sokajy,
    this.taonaNahaterahana,
    this.taonaNahafatesana,
  });

  factory Olomasina.fromMap(Map<String, dynamic> map) {
    return Olomasina(
      id: map['id'] as int?,
      anarana: map['anarana'] as String,
      datyFankalazana: map['daty_fankalazana'] as String,
      sary: map['sary'] as String?,
      fanoharana: map['fanoharana'] as String,
      tantara: map['tantara'] as String,
      sokajy: map['sokajy'] as String,
      taonaNahaterahana: map['taona_nahaterahana'] as String?,
      taonaNahafatesana: map['taona_nahafatesana'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'anarana': anarana,
      'daty_fankalazana': datyFankalazana,
      'sary': sary,
      'fanoharana': fanoharana,
      'tantara': tantara,
      'sokajy': sokajy,
      'taona_nahaterahana': taonaNahaterahana,
      'taona_nahafatesana': taonaNahafatesana,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}