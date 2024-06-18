import 'package:logger/logger.dart';

class DateHelper {
  Logger logger = Logger();
  static DateTime startOfToday() {
    return DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
  }

  static DateTime endOfToday() {
    return DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 23, 59, 59);
  }

  static DateTime startOfTomorrow() {
    return DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day + 1, 0, 0, 0);
  }

  static DateTime endOfTomorrow() {
    return DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day + 1, 23, 59, 59);
  }

  static DateTime startOfThisWeek() {
    return DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
  }

  static DateTime endOfThisWeek() {
    return DateTime.now().add(Duration(
      days: 7 - DateTime.now().weekday,
      hours: 23,
      minutes: 59,
      seconds: 59,
    ));
  }

  static DateTime startOfThisMonth() {
    return DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
  }

  static DateTime endOfThisMonth() {
    return DateTime(
        DateTime.now().year, DateTime.now().month + 1, 0, 23, 59, 59);
  }

  static DateTime startOfAll() {
    return DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
  }

  static DateTime endOfAll() {
    return DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 23, 59, 59)
        .add(const Duration(days: 31));
  }

  static DateTime past() {
    return DateTime(2020, 1, 1, 0, 0, 0);
  }
}
