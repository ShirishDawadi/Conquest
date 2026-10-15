class WeekUtils {
  static const switchHourUtc = 12;

  static DateTime _mondayOf(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day)
          .subtract(Duration(days: d.weekday - 1));

  static DateTime boardMonday() => _mondayOf(
    DateTime.now().toUtc().subtract(const Duration(hours: switchHourUtc)),
  );

  static bool isAheadOfBoard() {
    final now = DateTime.now();
    final localMonday = _mondayOf(DateTime(now.year, now.month, now.day));
    return localMonday.isAfter(boardMonday());
  }
}