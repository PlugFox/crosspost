import 'package:crosspost/src/common/social_gateway.dart';
import 'package:crosspost/src/common/social_post.dart';

/// {@template telegram_gateway.telegram_gateway}
/// Service for sending messages to Telegram
/// {@endtemplate}
class TelegramGateway extends SocialGateway {
  /// {@macro telegram_gateway.telegram_gateway}
  TelegramGateway({
    void Function(ISocialGatewayResponse response)? onDone,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) : super(onDone: onDone, onError: onError);

  @override
  Future<void> transform(ISocialPost post, Sink<ISocialGatewayRequest> sink) {
    // TODO: implement transform
    throw UnimplementedError();
  }

  @override
  Future<ISocialGatewayResponse> send(ISocialGatewayRequest request) {
    // TODO: implement send
    throw UnimplementedError();
  }
}
