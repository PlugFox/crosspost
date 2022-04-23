import 'package:crosspost/src/common/social_content.dart';
import 'package:meta/meta.dart';

/// {@template social_post.social_post}
/// Social post data class, container of social post content
///
/// Post contain one or more content.
/// Content could be text, photo, document, etc.
/// Content contain raw data and metadata.
/// {@endtemplate}
abstract class ISocialPost implements Iterable<ISocialContent> {
  /// Set new content to post
  ISocialPost set(ISocialContent content);

  /// Add new content to post
  ISocialPost add(ISocialContent content);

  /// Add all new content to post
  ISocialPost addAll(Iterable<ISocialContent> content);

  /// Remove content from post
  ISocialPost remove(ISocialContent content);

  /// Removes all objects from this list that satisfy [test].
  ISocialPost removeWhere(bool Function(ISocialContent content) test);

  /// Get content by index
  ISocialContent operator [](int index);
}

/// {@macro social_post.social_post}
@immutable
abstract class SocialPost extends Iterable<ISocialContent>
    implements ISocialPost {
  /// {@macro social_post.social_post}
  factory SocialPost(Object content) {
    if (content is String) {
      content = SocialContent.text(content);
    }
    if (content is ISocialContent) {
      return _SocialPostImpl(
        <ISocialContent>[
          content,
        ],
      );
    } else {
      // Automatic created social content from dynamic object
      throw UnimplementedError(
        'SocialPost can only be created from ISocialContent right now.',
      );
    }
  }

  /// {@macro social_post.social_post}
  factory SocialPost.join(
    final ISocialContent content1, [
    final ISocialContent? content2,
    final ISocialContent? content3,
    final ISocialContent? content4,
    final ISocialContent? content5,
    final ISocialContent? content6,
    final ISocialContent? content7,
    final ISocialContent? content8,
    final ISocialContent? content9,
    final ISocialContent? content10,
  ]) =>
      SocialPost.fromIterable(
        <ISocialContent>[
          content1,
          if (content2 != null) content2,
          if (content3 != null) content3,
          if (content4 != null) content4,
          if (content5 != null) content5,
          if (content6 != null) content6,
          if (content7 != null) content7,
          if (content8 != null) content8,
          if (content9 != null) content9,
          if (content10 != null) content10,
        ],
      );

  /// {@macro social_post.social_post}
  factory SocialPost.fromIterable(Iterable<ISocialContent> content) =>
      _SocialPostImpl(content.toList(growable: false));

  const SocialPost._(List<ISocialContent> content) : _source = content;

  final List<ISocialContent> _source;

  @override
  Iterator<ISocialContent> get iterator => _source.iterator;
}

@sealed
class _SocialPostImpl extends SocialPost with _ChangePostContentMixin {
  _SocialPostImpl(List<ISocialContent> content) : super._(content);

  @override
  int get length => _source.length;

  @override
  ISocialContent get last => _source.last;

  @override
  ISocialContent operator [](int index) => _source[index];
}

mixin _ChangePostContentMixin on SocialPost {
  @override
  ISocialPost set(ISocialContent content) => SocialPost.fromIterable(
        List<ISocialContent>.of(_source)
          ..remove(content)
          ..add(content),
      );

  @override
  ISocialPost add(ISocialContent content) => SocialPost.fromIterable(
        List<ISocialContent>.of(_source)..add(content),
      );

  @override
  ISocialPost addAll(Iterable<ISocialContent> content) =>
      SocialPost.fromIterable(
        List<ISocialContent>.of(_source)..addAll(content),
      );

  @override
  ISocialPost remove(ISocialContent content) => SocialPost.fromIterable(
        List<ISocialContent>.of(_source)..remove(content),
      );

  @override
  ISocialPost removeWhere(bool Function(ISocialContent content) test) =>
      SocialPost.fromIterable(
        List<ISocialContent>.of(_source)..removeWhere(test),
      );
}
