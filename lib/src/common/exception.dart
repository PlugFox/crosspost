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

/// {@template exception.api_exception}
/// API exception
/// {@endtemplate}
class APIException implements Exception {
  /// {@macro exception.api_exception}
  const APIException([this.message = 'API exception']);

  /// Message
  final String message;

  @override
  String toString() => message;
}
