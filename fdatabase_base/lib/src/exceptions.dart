abstract class FDatabaseException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const FDatabaseException(this.message, [this.stackTrace]);
}

class NotSupportedException extends FDatabaseException {
  const NotSupportedException(super.message, [super.stackTrace]);
}

class NotRegisteredException extends FDatabaseException {
  const NotRegisteredException(super.message, [super.stackTrace]);
}

class InvalidException extends FDatabaseException {
  const InvalidException(super.message, [super.stackTrace]);
}

class NestedListException extends FDatabaseException {
  const NestedListException([String? message, StackTrace? stackTrace]) : super(message ?? 'Nested list is not supported', stackTrace);
}
