class NullPointerException implements Exception {
  final String message;

  const NullPointerException({this.message});

  String toString() => 'NullPointerException: $message';
}
