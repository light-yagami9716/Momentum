import 'dart:math';

class IdGenerator {
  const IdGenerator._();

  static final Random _random = Random();

  static String newId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final suffix = _random.nextInt(0x7FFFFFFF).toRadixString(36);
    return '$timestamp-$suffix';
  }
}
