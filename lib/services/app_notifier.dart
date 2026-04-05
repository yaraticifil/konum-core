import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/error_model.dart';
import '../models/log_severity.dart';
import 'error_logger_service.dart';

class AppNotifier {
  static final ErrorLoggerService _logger = ErrorLoggerService();

  static Future<void> snackbar(
    String title,
    String message, {
    LogSeverity severity = LogSeverity.medium,
    String source = 'ui',
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? colorText,
  }) async {
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      duration: duration,
      backgroundColor: backgroundColor ?? _severityColor(severity),
      colorText: colorText ?? Colors.white,
    );

    await _logger.logSnackbar(
      title: title,
      message: message,
      source: source,
      severity: severity,
    );
  }

  static Color _severityColor(LogSeverity severity) {
    switch (severity) {
      case LogSeverity.low:
        return Colors.blueGrey;
      case LogSeverity.medium:
        return Colors.orange;
      case LogSeverity.critical:
        return Colors.redAccent;
    }
  }

  static Future<void> error({
    required String code,
    required String message,
    required String source,
    Map<String, dynamic>? metadata,
  }) {
    return _logger.log(
      ErrorModel(
        code: code,
        message: message,
        source: source,
        occurredAt: DateTime.now(),
        metadata: metadata,
      ),
      severity: LogSeverity.critical,
    );
  }
}
