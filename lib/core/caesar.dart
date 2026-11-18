/// Kilasy famahana (decrypt) ny lahatsoratra voahodina ao anaty
/// `smc.db`. Ity no fomba (algorithm) TENA NAMPIASAINA hanafenana
/// ny angona — noraisina avy amin'ny app niaviana (Java/Kotlin,
/// nadika ho Dart), ka tsy tokony hovaina raha tsy misy antony
/// manokana.
///
/// Fampiasana:
/// ```dart
/// final votoatiny = Caesar.decrypt(rawText, AppConstants.caesarKey);
/// ```
///
/// FANOVANA TOKANA (antony: PERFORMANCE, tsy misy fiovan'ny valiny):
/// ny `_generateKey` taloha dia nanao `currentKey.toString()[i]` isaky ny
/// tsingerina, izany hoe namorona String vaovao lava be isaky ny
/// tsingerina => O(n²). Ho an'ny andininy 5 000-10 000 litera dia nahatonga
/// ny UI hihotsaka rehefa mamaky angona. Ankehitriny ny key dia
/// averimberina (cyclic) mivantana amin'ny `i % key.length` => O(n), ary
/// MITOVY tanteraka ny valiny (jereo `test/caesar_test.dart` izay
/// mampitaha amin'ny implementation taloha).
class Caesar {
  Caesar._();

  static const int _shift = 11;

  static String encrypt(String str, String keyword) {
    _checkKey(keyword);
    final cipherText = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      // codeUnitAt(i) no maka ny sandan'ny character amin'ny ASCII/UTF-16
      int x = (str.codeUnitAt(i) + _keyUnit(keyword, i)) % 65536;
      x += _shift;

      // String.fromCharCode() no mamadika ny isa ho character indray
      cipherText.write(String.fromCharCode(x));
    }
    return cipherText.toString();
  }

  static String decrypt(String cipherText, String keyword) {
    _checkKey(keyword);
    final origText = StringBuffer();

    for (int i = 0; i < cipherText.length; i++) {
      int x = (cipherText.codeUnitAt(i) - _keyUnit(keyword, i) + 65536) % 65536;
      x -= _shift;

      origText.write(String.fromCharCode(x));
    }
    return origText.toString();
  }

  /// Litera faha-[i] amin'ny key averimberina (cyclic) hatramin'ny halavan'ny
  /// lahatsoratra: "zakaranda" => z a k a r a n d a z a k ...
  static int _keyUnit(String key, int i) => key.codeUnitAt(i % key.length);

  static void _checkKey(String key) {
    if (key.isEmpty) {
      throw ArgumentError.value(key, 'keyword', 'Tsy azo atao foana ny key.');
    }
  }
}
