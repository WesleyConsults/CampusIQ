class DeepSeekException implements Exception {
  final String message;
  final int? statusCode;
  const DeepSeekException(this.message, {this.statusCode});

  @override
  String toString() => 'DeepSeekException($statusCode): $message';
}
