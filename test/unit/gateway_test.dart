// ignore_for_file: close_sinks, unnecessary_lambdas

import 'package:crosspost/src/common/exception.dart';
import 'package:crosspost/src/common/social_content.dart';
import 'package:crosspost/src/common/social_gateway.dart';
import 'package:crosspost/src/common/social_post.dart';
import 'package:crosspost/src/gateway/telegram/telegram_gateway.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'gateway_test.mocks.dart' as mocks;

void main() => group(
      'gateway',
      () {
        group('telegram', _telegram);
        group('webhook', _webhook);
      },
    );

@GenerateMocks([http.Client])
void _telegram() {
  test('constructor', () async {
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
    );
    expect(telegram, isA<SocialGateway>());
    await expectLater(telegram.initialized, completes);
    expect(telegram.isInitialized, isTrue);
    await expectLater(telegram.close(), completes);
  });

  test('initialize_and_close_succesful', () async {
    final client = mocks.MockClient();
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
      httpClient: client,
    );

    expect(telegram.isInitialized, isFalse);
    await telegram.initialized;
    expect(telegram.isInitialized, isTrue);
    expect(telegram.isClosed, isFalse);
    await telegram.close();
    expect(telegram.isClosed, isTrue);
    expect(telegram.isInitialized, isFalse);
    verifyNever(client.send(any));
    verifyNever(client.close());
    verifyZeroInteractions(client);
    client.close();
    verify(client.close()).called(1);
  });

  test('add', () async {
    final client = mocks.MockClient();
    when(
      client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '{"ok":true}',
        200,
      ),
    );
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
      httpClient: client,
    );
    await telegram.add(SocialPost(SocialContent.text('test')));
    verify(
      client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).called(1);
    await telegram.close();
    expect(telegram.isClosed, isTrue);
    expect(telegram.isInitialized, isFalse);
    verifyNever(client.close());
    client.close();
    verify(client.close()).called(1);
  });

  test('send_message', () async {
    final client = mocks.MockClient();
    when(
      client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '{"ok":true}',
        200,
      ),
    );
    var rspCount = 0;
    var errCount = 0;
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
      httpClient: client,
      onDone: (rsp) => rspCount++,
      onError: (Object obj, StackTrace st) => errCount++,
    );
    expect(rspCount, equals(0));
    expect(errCount, equals(0));
    await telegram.add(SocialPost(SocialContent.text('test')));
    verify(
      client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).called(1);
    await telegram.close();
    expect(telegram.isClosed, isTrue);
    expect(telegram.isInitialized, isFalse);
    expect(rspCount, equals(1));
    expect(errCount, equals(0));
    verifyNever(client.close());
    client.close();
    verify(client.close()).called(1);
  });

  test('auth_exception', () async {
    final client = mocks.MockClient();
    when(
      client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '{"ok":false}',
        401,
      ),
    );
    var rspCount = 0;
    var errCount = 0;
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
      httpClient: client,
      onDone: (rsp) => rspCount++,
      onError: (Object obj, StackTrace st) => errCount++,
    );
    expect(rspCount, equals(0));
    expect(errCount, equals(0));
    await expectLater(
      telegram.add(SocialPost(SocialContent.text('test'))),
      throwsA(isA<AuthenticationException>()),
    );
    verify(
      client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).called(1);
    await telegram.close();
    expect(telegram.isClosed, isTrue);
    expect(telegram.isInitialized, isFalse);
    expect(rspCount, equals(0));
    expect(errCount, equals(1));
    verifyNever(client.close());
    client.close();
    verify(client.close()).called(1);
  });

  test('throw_network_exception', () async {
    final client = mocks.MockClient();
    when(
      client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenThrow(Exception('Fake network exception'));
    var rspCount = 0;
    var errCount = 0;
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
      httpClient: client,
      onDone: (rsp) => rspCount++,
      onError: (Object obj, StackTrace st) => errCount++,
    );
    expect(rspCount, equals(0));
    expect(errCount, equals(0));
    await expectLater(
      telegram.add(SocialPost(SocialContent.text('test'))),
      throwsException,
    );
    verify(
      client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).called(1);
    await telegram.close();
    expect(telegram.isClosed, isTrue);
    expect(telegram.isInitialized, isFalse);
    expect(rspCount, equals(0));
    expect(errCount, equals(1));
    verifyNever(client.close());
    client.close();
    verify(client.close()).called(1);
  });

  test('add_error', () async {
    var errors = 0;
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
      onError: (Object _, StackTrace __) => errors++,
    );
    expect(telegram, isA<SocialGateway>());
    expect(errors, equals(0));
    telegram.addError(Exception('test'));
    expect(errors, equals(1));
    await expectLater(telegram.initialized, completes);
    telegram.addError(Exception('test'));
    expect(errors, equals(2));
    await expectLater(telegram.close(), completes);
  });

  test('add_empty_post', () async {
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
    );
    await expectLater(
      () => telegram.add(SocialPost.fromIterable(const <ISocialContent>[])),
      throwsArgumentError,
    );
    await expectLater(telegram.close(), completes);
  });

  test('add_after_close', () async {
    final telegram = TelegramGateway(
      token: '1',
      chatID: '1',
    );
    await expectLater(telegram.close(), completes);
    await expectLater(
      () => telegram.add(SocialPost(SocialContent.text('test'))),
      throwsStateError,
    );
  });
}

void _webhook() {
  test('placeholder', () {
    expect(true, isTrue);
  });
}
