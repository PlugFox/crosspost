/// {@template exception.auth_exception}
/// Authexception exception
/// {@endtemplate}
class AuthenticationException implements Exception {
  /// {@macro exception.auth_exception}
  const AuthenticationException([this.message = 'Authentication failed']);

  /// Message
  final String message;

  @override
  String toString() => message;
}
