class DateVO {
  final DateTime value;

  DateVO(this.value) {
    final now = DateTime.now();
    final tenYearsAgo = DateTime(now.year - 10, now.month, now.day);
    if (value.isAfter(now.add(const Duration(days: 7)))) {
      throw ArgumentError('Date cannot be more than 7 days in the future');
    }
    if (value.isBefore(tenYearsAgo)) {
      throw ArgumentError('Date cannot be older than 10 years');
    }
  }

  @override
  String toString() => value.toIso8601String();
}
