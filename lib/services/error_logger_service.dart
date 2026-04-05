import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/error_model.dart';

class ErrorLoggerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> log(ErrorModel error) async {
    try {
      await _firestore.collection('system_logs').add({
        ...error.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('System log write failed: $e');
    }
  }
}
