import 'package:args/args.dart';
import 'package:crosspost/crosspost.dart';
import 'package:meta/meta.dart';

void main(List<String> args) => Future<void>(() async {
      final data = _Arguments.fromIterable(args);
      final gateway = TelegramGateway(token: data.token, chatID: data.chatID);
      await gateway.add(SocialPost('Hello world!'));
      await gateway.close();
    });

@immutable
class _Arguments {
  const _Arguments({
    required this.token,
    required this.chatID,
    required this.message,
  });

  factory _Arguments.fromIterable(Iterable<String> args) {
    final parser = ArgParser()
      ..addOption(
        'token',
        abbr: 't',
        help: 'Telegram bot token',
        mandatory: true,
      )
      ..addOption(
        'chat',
        abbr: 'c',
        help: 'Telegram chat id',
        mandatory: true,
      )
      ..addOption(
        'message',
        abbr: 'm',
        help: 'Telegram message',
        mandatory: false,
        defaultsTo: 'Hello world!',
      );
    final parsed = parser.parse(args);
    return _Arguments(
      token: parsed['token']!.toString(),
      chatID: parsed['chat']!.toString(),
      message: parsed['message']?.toString() ?? 'Hello world!',
    );
  }

  final String token;
  final String chatID;
  final String message;

  @override
  String toString() => 'token: $token\n'
      'chatID: $chatID';
}
