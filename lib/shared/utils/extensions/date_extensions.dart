import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String toFormattedDate() {
    final formatter = DateFormat('yyyy/MM/dd');
    return formatter.format(this);
  }

  String toDbFormat() {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(this);
  }
}
