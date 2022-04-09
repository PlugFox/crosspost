import 'dart:async';
import 'package:crosspost/src/common/social_post.dart';
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
abstract class ISocialGateway<Req extends ISocialGatewayRequest,
        Rsp extends ISocialGatewayResponse>
    implements EventSink<ISocialPost>, IClosable {
  /// Is gateway is already initialized
  bool get isInitialized;
}

/// {@macro social_gateway.social_gateway}
///
/// Pipeline stream:
/// [add] => [transform] => [send] => [onDone]
///
/// Calling [onDone] callback on every successful [send]
/// Calling [onError] callback on every exception
abstract class SocialGateway<Req extends ISocialGatewayRequest,
    Rsp extends ISocialGatewayResponse> implements ISocialGateway<Req, Rsp> {
  /// {@macro social_gateway.social_gateway}
  SocialGateway({
    void Function(Rsp response)? onDone,
    void Function(Object error, StackTrace stackTrace)? onError,
  })  : onDone = onDone ?? _onDoneByDefault,
        onError = onError ?? _onErrorByDefault {
    (_completer..complete(initialize()))
        .future
        .timeout(const Duration(minutes: 5))
        .then<void>(
      (_) => _isInitialized = true,
      onError: (Object e, StackTrace stackTrace) {
        this.onError(e, StackTrace.current);
      },
    );
  }

  static void _onDoneByDefault(ISocialGatewayResponse response) {}

  static void _onErrorByDefault(Object error, StackTrace stackTrace) {}

  @override
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;
  final Completer<void> _completer = Completer<void>();

  /// Fires when the gateway is initialized
  Future<void> get initialized =>
      _completer.future.timeout(const Duration(minutes: 5));

  @override
  bool get isClosed => _isClosed;
  bool _isClosed = false;

  /// Initialize social gateway.
  @protected
  @mustCallSuper
  Future<void> initialize() async {
    assert(!isInitialized, 'Social gateway is already initialized');
  }

  /// Called whenever an error occurs.
  @protected
  @mustCallSuper
  final void Function(Object error, StackTrace stackTrace) onError;

  /// Called whenever a [SocialPost] successfully sended.
  @protected
  @mustCallSuper
  final void Function(Rsp response) onDone;

  /// Filter, validate, transform and prepare post to send to social network
  @protected
  Future<void> transform(ISocialPost post, Sink<Req> sink);

  /// Send request to social network
  @protected
  Future<Rsp> send(Req request);

  @protected
  @mustCallSuper
  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  @override
  @mustCallSuper
  Future<void> close() async {
    assert(!isClosed, 'Social gateway is already closed');
    await initialized;
    assert(isInitialized, 'Social gateway is not initialized');
    _isClosed = true;
    _isInitialized = false;
  }

  @override
  void add(ISocialPost post) {
    assert(!isClosed, 'gateway must not be closed');
    assert(post.isNotEmpty, 'post must not be empty');
    if (isClosed) {
      final error = StateError('gateway must not be closed');
      onError(error, StackTrace.current);
      throw error;
    }
    if (post.isEmpty) {
      final error = ArgumentError.value(post, 'post', 'post must not be empty');
      onError(error, StackTrace.current);
      throw error;
    }
    final Stream<void> stream;
    if (isInitialized) {
      stream = const Stream<void>.empty();
    } else {
      stream = Stream<void>.fromFuture(_completer.future);
    }
    stream
        .transform<Req>(
          StreamTransformer.fromHandlers(
            handleData: (void _, EventSink<Req> sink) {
              transform(post, sink);
            },
          ),
        )
        .asyncMap<Rsp>(send)
        .timeout(const Duration(minutes: 2))
        .listen(
          onDone,
          onError: onError,
          cancelOnError: false,
        );
  }
}
