extension DateTimeX on DateTime {
  String getWaveFormat({DateTime? endDateTime}) {
    if (endDateTime == null) {
      return '$year.$month ~';
    }

    return '$year.$month ~ ${endDateTime.year}.${endDateTime.month}';
  }
}
