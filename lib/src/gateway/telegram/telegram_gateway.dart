import 'dart:convert';

import 'package:crosspost/src/common/exception.dart';
import 'package:crosspost/src/common/social_content.dart';
import 'package:crosspost/src/common/social_gateway.dart';
import 'package:crosspost/src/common/social_gateway_base.dart';

import 'package:http/http.dart' as http;

/// {@template telegram_gateway.telegram_gateway}
/// Service for sending messages to Telegram
/// {@endtemplate}
class TelegramGateway
    extends SocialGatewayBase<_TelegramRequest, TelegramResponse>
    with _TransformTelegramRequestMixin {
  /// {@macro telegram_gateway.telegram_gateway}
  TelegramGateway({
    // Telegram bot token
    required String token,
    // Telegram chat id
    required String chatID,
    // Markdown, MarkdownV2, HTML
    String parseMode = 'MarkdownV2',
    http.Client? httpClient,
    void Function(TelegramResponse response)? onDone,
    void Function(Object error, StackTrace stackTrace)? onError,
  })  : _token = token,
        _chatID = chatID,
        _parseMode = parseMode,
        _client = httpClient ?? http.Client(),
        _internalClient = httpClient == null,
        super(onDone: onDone, onError: onError);

  final String _token;
  final String _parseMode;
  final String _chatID;
  final bool _internalClient;
  final http.Client _client;

  @override
  Future<TelegramResponse> send(_TelegramRequest request) async {
    final response = await _client.post(
      Uri.parse('https://api.telegram.org/bot$_token/sendMessage'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, Object?>{
          'chat_id': _chatID,
          'text': request.message,
          'disable_notification': false,
          'parse_mode': _parseMode,
        },
      ),
    );
    if (response.statusCode == 200) {
      return TelegramResponse.fromJson(
        jsonDecode(response.body) as Map<String, Object?>,
      );
    } else {
      throw AuthenticationException(
        'Telegram response status code: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> close() {
    if (_internalClient) {
      _client.close();
    }
    return super.close();
  }
}

/// Telegram request representation
class _TelegramRequest implements ISocialGatewayRequest {
  _TelegramRequest({
    required this.message,
  }) : assert(
          message == null || message.length <= maxMessageLength,
          'Message is too long',
        );

  static const int maxMessageLength = 4096;

  final String? message;
}

/// {@template telegram_gateway.telegram_response}
/// Telegram response representation
/// {@endtemplate}
class TelegramResponse implements ISocialGatewayResponse {
  /// {@macro telegram_gateway.telegram_response}
  const TelegramResponse();

  /// Create Telegram response from JSON
  factory TelegramResponse.fromJson(Map<String, Object?> json) =>
      const TelegramResponse();
}

mixin _TransformTelegramRequestMixin
    on SocialGatewayBase<_TelegramRequest, TelegramResponse> {
  @override
  Future<void> transform(
    Iterable<ISocialContent> post,
    Sink<_TelegramRequest> sink,
  ) async {
    final buffer = StringBuffer();
    for (final content in post) {
      content.maybeMap<void>(
        orElse: () {},
        text: (content) => buffer.writeln(content.data.text),
      );
    }
    String? message;
    if (buffer.isNotEmpty) {
      message = (buffer.length > _TelegramRequest.maxMessageLength)
          ? buffer.toString().substring(0, _TelegramRequest.maxMessageLength)
          : buffer.toString();
    }
    if (message == null) return;
    sink.add(
      _TelegramRequest(
        message: message,
      ),
    );
  }
}
