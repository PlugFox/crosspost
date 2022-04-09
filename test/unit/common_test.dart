// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:crosspost/src/common/social_content.dart';
import 'package:crosspost/src/common/social_content_data.dart';
import 'package:crosspost/src/common/social_post.dart';
import 'package:test/test.dart';

void main() => group(
      'common',
      () {
        group(
          'social_post',
          _socialPostTest,
        );
        group(
          'social_content',
          _socialContent,
        );
        group(
          'content_data',
          _contentData,
        );
        group(
          'social_gateway',
          _socialGateway,
        );
      },
    );

void _socialPostTest() {
  setUpAll(
    () {},
  );

  test('constructors', () {
    expect(SocialPost(SocialContent.text('text')), isA<SocialPost>());
    expect(
      SocialPost.fromIterable(
        <ISocialContent>[
          SocialContent.text('text'),
          SocialContent.text('text2'),
        ],
      ),
      isA<SocialPost>(),
    );
    expect(SocialPost.join(SocialContent.text('text')), isA<SocialPost>());
    expect(
      SocialPost.join(
        SocialContent.text('text'),
        SocialContent.text('text'),
        SocialContent.text('text'),
      ).length,
      equals(3),
    );
    expect(
      SocialPost.join(
        SocialContent.text('text1'),
        SocialContent.text('text2'),
        SocialContent.text('text3'),
        SocialContent.text('text4'),
        SocialContent.text('text5'),
        SocialContent.text('text6'),
        SocialContent.text('text7'),
        SocialContent.text('text8'),
        SocialContent.text('text9'),
        SocialContent.text('text0'),
      ).length,
      equals(10),
    );
  });

  test('collection', () {
    final post = SocialPost(SocialContent.text('text'));
    expect(post.length, 1);
    expect(post.first, SocialContent.text('text'));
    expect(post.first, same(post[0]));
    expect(post.last, SocialContent.text('text'));
    expect(post.single, SocialContent.text('text'));
    expect(post.isEmpty, false);
    expect(post.isNotEmpty, true);
    expect(post.contains(SocialContent.text('text')), isTrue);
    expect(post.contains(SocialContent.text('text2')), isFalse);
    expect(post.elementAt(0), SocialContent.text('text'));
    expect(() => post.elementAt(1), throwsA(isA<RangeError>()));
    expect(
      post.firstWhere((content) => content.textOrNull == 'text'),
      SocialContent.text('text'),
    );
    expect(SocialContent.text('text'), isIn(post));
    expect(
      () => post.firstWhere((content) => content.textOrNull == 'text2'),
      throwsStateError,
    );
    expect(
      post.lastWhere((content) => content.textOrNull == 'text'),
      SocialContent.text('text'),
    );
    expect(
      () => post.lastWhere((content) => content.textOrNull == 'text2'),
      throwsStateError,
    );
    expect(
      post.singleWhere((content) => content.textOrNull == 'text'),
      SocialContent.text('text'),
    );
    expect(
      () => post.singleWhere((content) => content.textOrNull == 'text2'),
      throwsStateError,
    );
    expect(
      post.where((content) => content.textOrNull == 'text'),
      <SocialContent>[SocialContent.text('text')],
    );
    expect(
      post.where((content) => content.textOrNull == 'text2'),
      isEmpty,
    );
  });

  test(
    'merging',
    () {
      final post = SocialPost(SocialContent.text('text'));
      expect(
        post.add(SocialContent.text('text2')),
        isA<SocialPost>(),
      );
      expect(
        post.add(SocialContent.text('text2')).length,
        equals(2),
      );
      expect(
        post.addAll(
          <SocialContent>[
            SocialContent.text('text2'),
            SocialContent.text('text3'),
          ],
        ).length,
        equals(3),
      );
      expect(
        post
            .addAll(
              <SocialContent>[
                SocialContent.text('text2'),
                SocialContent.text('text3'),
              ],
            )
            .remove(SocialContent.text('text2'))
            .length,
        equals(2),
      );
      expect(post.set(SocialContent.text('text')).length, equals(1));
      expect(post.remove(SocialContent.text('text')), isEmpty);
      expect(post.remove(SocialContent.text('text2')), isNotEmpty);
      expect(post.removeWhere((c) => c.textOrNull == 'text'), isEmpty);
      expect(post.removeWhere((c) => c.textOrNull == 'text2'), isNotEmpty);
    },
  );
}

void _socialContent() {
  test(
    'constructors',
    () {
      expect(SocialContent.text('text'), isA<SocialContent>());
      expect(SocialContent.text('text'), equals(SocialContent.text('text')));
      expect(
        SocialContent.text('text'),
        isNot(equals(SocialContent.text('text2'))),
      );
    },
  );

  test(
    'maybe_map',
    () {
      final content = SocialContent.text('text');
      expect(
        content.maybeMap<ISocialContent?>(
          text: (content) => content,
          orElse: () => null,
        ),
        same(content),
      );
      expect(
        content.maybeMap<ISocialContent?>(
          photo: (content) => content,
          document: (content) => content,
          orElse: () => null,
        ),
        isNull,
      );
      expect(
        content.maybeMap<ISocialContent?>(
          orElse: () => null,
        ),
        isNull,
      );
      expect(
        () => content.maybeMap<ISocialContent?>(
          orElse: () => throw Exception('orElse'),
        ),
        throwsException,
      );
      expect(
        content.maybeMap<Object?>(
          orElse: () => 1,
          text: (content) => 2,
          photo: (content) => 3,
          document: (content) => 4,
        ),
        equals(2),
      );
    },
  );

  test(
    'hash_code',
    () {
      expect(SocialContent.text('text').hashCode, isNot(equals(0)));
      expect(
        SocialContent.text('text').hashCode,
        equals(SocialContent.text('text').hashCode),
      );
      expect(
        SocialContent.text('text').hashCode,
        isNot(equals(SocialContent.text('text2').hashCode)),
      );
    },
  );
}

void _contentData() {
  test(
    'constructor',
    () {
      expect(TextContentData.text('text'), isA<ISocialContentData>());
      expect(TextContentData.text('text'), isA<ITextContentData>());
      expect(TextContentData.text('text'), isA<TextContentData>());
      expect(
        TextContentData.text('text'),
        equals(TextContentData.text('text')),
      );
      expect(
        TextContentData.text('text'),
        isNot(equals(TextContentData.text('text2'))),
      );
    },
  );

  test(
    'maybe_map',
    () {
      final data = TextContentData.text('text');
      expect(data.maybeWhen<String?>(orElse: () => null), isNull);
      expect(
        data.maybeWhen<String?>(orElse: () => null, string: (s) => s),
        isNotNull,
      );
      expect(
        data.maybeWhen<String?>(orElse: () => null, string: (s) => s),
        equals('text'),
      );
      expect(
        data.maybeWhen<String?>(orElse: () => null, string: (s) => s),
        same('text'),
      );
      expect(
        () => data.maybeWhen<String?>(orElse: () => throw Exception('orElse')),
        throwsA(isA<Exception>()),
      );
    },
  );
}

void _socialGateway() {
  test('completer', () {
    expectLater(
      (Completer<bool>()..complete(Future<bool>.value(true))).future,
      completion(same(true)),
    );
    expectLater(
      () => Completer<bool>()
        ..complete(Future<bool>.value(true))
        ..complete(Future<bool>.value(false)),
      throwsStateError,
    );
    expectLater(
      () => Completer<bool>()
        ..complete(
          Future<bool>.delayed(Duration(milliseconds: 50), () => true),
        )
        ..complete(
          Future<bool>.delayed(Duration(milliseconds: 50), () => false),
        ),
      throwsStateError,
    );
  });
}
