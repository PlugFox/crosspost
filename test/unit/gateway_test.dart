// ignore_for_file: close_sinks, unnecessary_lambdas

import 'package:crosspost/src/common/social_gateway.dart';
import 'package:crosspost/src/gateway/telegram/telegram_gateway.dart';
import 'package:test/test.dart';

void main() => group(
      'gateway',
      () {
        group('telegram', _telegram);
        group('webhook', _webhook);
      },
    );

void _telegram() {
  test('constructor', () {
    final telegram = TelegramGateway();
    expectLater(telegram.initialized, completes);
    expectLater(telegram.close(), completes);
    expect(telegram, isA<SocialGateway>());
  });

  test('initialize_and_close_succesful', () async {
    final telegram = TelegramGateway();
    expect(telegram.isInitialized, isFalse);
    await telegram.initialized;
    expect(telegram.isInitialized, isTrue);
    expect(telegram.isClosed, isFalse);
    await telegram.close();
    expect(telegram.isClosed, isTrue);
    expect(telegram.isInitialized, isFalse);
  });
}

void _webhook() {
  test('placeholder', () {
    expect(true, isTrue);
  });
}
