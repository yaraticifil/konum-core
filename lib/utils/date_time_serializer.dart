import 'package:cloud_firestore/cloud_firestore.dart';

class DateTimeSerializer {
  const DateTimeSerializer._();

  static DateTime fromFirestore(dynamic value, {DateTime? fallback}) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return fallback ?? DateTime.now();
  }

  static DateTime? fromFirestoreNullable(dynamic value) {
    if (value == null) return null;
    return fromFirestore(value);
  }

  static Timestamp toTimestamp(DateTime value) => Timestamp.fromDate(value);
}
