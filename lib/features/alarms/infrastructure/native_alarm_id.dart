import 'dart:convert';

abstract final class NativeAlarmId {
  static int fromOccurrenceId(String occurrenceId) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(occurrenceId)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    final positive = hash & 0x7fffffff;
    return positive == 0 ? 1 : positive;
  }
}
