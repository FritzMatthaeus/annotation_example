class CachedModelManagerException implements Exception {
  final String message;
  final StackTrace stackTrace;
  const CachedModelManagerException(this.message, this.stackTrace);

  @override
  String toString() => 'CachedModelManagerException(message: $message)';
}
