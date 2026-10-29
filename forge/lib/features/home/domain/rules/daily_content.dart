/// Index of the daily item (quote, tip) for [date], cycling through [count].
int dailyIndex(DateTime date, int count) {
  final dayOfYear = date.difference(DateTime(date.year)).inDays;
  return dayOfYear % count;
}
