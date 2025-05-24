class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null) {
      return 'ApiException: $message (status: $statusCode)\nErrors: ${errors!.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
    }
    return 'ApiException: $message (status: $statusCode)';
  }
}
