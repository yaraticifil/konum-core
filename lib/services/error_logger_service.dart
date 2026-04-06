import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/error_model.dart';
import '../models/log_severity.dart';

abstract class ObservabilityService {
  Future<void> capture({
    required String event,
    required LogSeverity severity,
    required Map<String, dynamic> payload,
  });
}

class DebugObservabilityService implements ObservabilityService {
  @override
  Future<void> capture({
    required String event,
    required LogSeverity severity,
    required Map<String, dynamic> payload,
  }) async {
    debugPrint('[observability][$event][${severity.name}] $payload');
  }
}

class ErrorLoggerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ObservabilityService _observability;

  ErrorLoggerService({ObservabilityService? observability})
      : _observability = observability ?? DebugObservabilityService();

  Future<void> log(ErrorModel error, {LogSeverity severity = LogSeverity.medium}) async {
    try {
      final payload = {
        ...error.toMap(),
        'severity': severity.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('system_logs').add(payload);
      await _observability.capture(
        event: 'system_error',
        severity: severity,
        payload: payload,
      );
    } catch (e) {
      debugPrint('System log write failed: $e');
    }
  }

  Future<void> logSnackbar({
    required String title,
    required String message,
    required String source,
    LogSeverity severity = LogSeverity.medium,
  }) async {
    try {
      final payload = {
        'code': 'UI_SNACKBAR',
        'title': title,
        'message': message,
        'source': source,
        'severity': severity.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('system_logs').add(payload);
      await _observability.capture(
        event: 'ui_snackbar',
        severity: severity,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Snackbar log write failed: $e');
    }
  }
}
