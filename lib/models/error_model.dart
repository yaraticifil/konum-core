class ErrorModel {
  final String code;
  final String message;
  final String source;
  final DateTime occurredAt;
  final Map<String, dynamic>? metadata;

  const ErrorModel({
    required this.code,
    required this.message,
    required this.source,
    required this.occurredAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'source': source,
      'occurredAt': occurredAt.toIso8601String(),
      'metadata': metadata ?? {},
    };
  }
}
