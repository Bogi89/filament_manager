class PrintDurationFormatter {
  const PrintDurationFormatter._();

  static String format(double minutes) {
    if (!minutes.isFinite || minutes < 0) return '0 min';
    final rounded = minutes.round();
    final hours = rounded ~/ 60;
    final remainder = rounded % 60;
    if (hours == 0) return '$remainder min';
    if (remainder == 0) return '$hours h';
    return '$hours h $remainder min';
  }
}
