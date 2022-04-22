import 'dart:async';
import 'package:crosspost/src/common/exception.dart';
import 'package:crosspost/src/common/social_content.dart';
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
    implements EventSink<Iterable<ISocialContent>>, IClosable {
  /// Is gateway is already initialized
  bool get isInitialized;

  /// Add and send post to social network
  @override
  Future<void> add(Iterable<ISocialContent> post);
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
    runZonedGuarded<void>(() async {
      await initialize().then<void>((_) {
        _isInitialized = true;
        _initCompleter.complete();
      }).timeout(const Duration(minutes: 5));
    }, (Object error, StackTrace stackTrace) {
      _isInitialized = false;
      //_initCompleter.completeError(error, stackTrace);
      _initCompleter.complete();
      this.onError(error, stackTrace);
    });
  }

  static void _onDoneByDefault(ISocialGatewayResponse response) {}

  static void _onErrorByDefault(Object error, StackTrace stackTrace) {}

  @override
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  /// Fires when the gateway is initialized
  Future<void> get initialized =>
      _initCompleter.future.timeout(const Duration(minutes: 5));

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
  Future<void> transform(Iterable<ISocialContent> post, Sink<Req> sink);

  /// Send request to social network
  @protected
  Future<Rsp> send(Req request);

  @override
  @protected
  @visibleForTesting
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  @override
  @mustCallSuper
  Future<void> close() async {
    assert(!isClosed, 'Social gateway is already closed');
    await initialized;
    _isClosed = true;
    _isInitialized = false;
  }

  @override
  Future<void> add(Iterable<ISocialContent> post) {
    if (isClosed) {
      final error = StateError('gateway must not be closed');
      onError(error, StackTrace.current);
      throw error;
    }
    if (post.isEmpty) {
      final error = EmptyPostException();
      onError(error, StackTrace.current);
      throw error;
    }
    final Stream<void> stream;
    if (isInitialized) {
      stream = const Stream<void>.empty();
    } else {
      stream = Stream<void>.fromFuture(_initCompleter.future);
    }
    final completer = Completer<void>();
    stream
        .transform<Req>(
          StreamTransformer<void, Req>.fromHandlers(
            handleData: (void _, EventSink<Req> sink) {
              transform(post, sink);
            },
          ),
        )
        .asyncMap<Rsp>(send)
        .timeout(const Duration(minutes: 2))
        .listen(
          onDone,
          onError: (Object error, StackTrace stackTrace) {
            onError(error, stackTrace);
            completer.completeError(error, stackTrace);
          },
          cancelOnError: true,
          onDone: completer.isCompleted ? null : completer.complete,
        );
    return completer.future;
  }
}
