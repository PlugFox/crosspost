import 'dart:async';
import 'package:crosspost/src/common/social_content.dart';
import 'package:meta/meta.dart';

/// {@template social_gateway.social_gateway_request}
/// Request to social gateway.
/// {@endtemplate}
abstract class ISocialGatewayRequest {}

/// {@template social_gateway.social_gateway_response}
/// Response from social gateway.
/// {@endtemplate}
abstract class ISocialGatewayResponse {}

/// An object that must be closed when no longer in use.
abstract class IClosable {
  /// Whether the object is closed.
  ///
  /// An object is considered closed once [close] is called.
  bool get isClosed;

  /// Closes the current instance.
  /// The returned future completes when the instance has been closed.
  @mustCallSuper
  Future<void> close();
}

/// {@template social_gateway.social_gateway}
/// Using for social network services
/// {@endtemplate}
abstract class ISocialGateway
    implements EventSink<Iterable<ISocialContent>>, IClosable {
  /// Is gateway is already initialized
  bool get isInitialized;

  /// Add and send post to social network
  @override
  Future<void> add(Iterable<ISocialContent> post);
}
