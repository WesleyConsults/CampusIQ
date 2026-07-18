import 'dart:math';

final Random _secureRandom = Random.secure();

String createStableTimetableId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final randomPart = List<int>.generate(
    8,
    (_) => _secureRandom.nextInt(256),
  ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return 'tt_${now.toRadixString(16)}_$randomPart';
}
