class CachedAnnotationException implements Exception {
  final String message;
  final StackTrace stackTrace;
  const CachedAnnotationException(this.message, this.stackTrace);

  @override
  String toString() => 'CachedAnnotationException(message: $message)';
}
