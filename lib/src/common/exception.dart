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

/// {@template exception.empty_post_exception}
/// Argument errpr: post must not be empty
/// {@endtemplate}
class EmptyPostException extends ArgumentError {
  /// {@macro exception.empty_post_exception}
  EmptyPostException([Object message = 'Post must not be empty'])
      : super(message, 'post');
}
