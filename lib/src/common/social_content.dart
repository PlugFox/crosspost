import 'package:crosspost/src/common/social_content_data.dart';
import 'package:meta/meta.dart';

/// {@template social_content.social_content}
/// Social post content:
/// - text
/// - photo
/// - document
/// {@endtemplate}
abstract class ISocialContent {
  /// Content data
  abstract final ISocialContentData data;

  /// Return text content if this content is text
  String? get textOrNull;

  /// Content selector
  T maybeMap<T extends Object?>({
    required T Function() orElse,
    T Function(ITextContent content)? text,
    T Function(IPhotoContent content)? photo,
    T Function(IDocumentContent content)? document,
  });
}

/// {@template social_content.text_content}
/// Social post content with text.
/// {@endtemplate}
abstract class ITextContent implements ISocialContent {}

/// {@template social_content.photo_content}
/// Social post content with photo.
/// {@endtemplate}
abstract class IPhotoContent implements ISocialContent {}

/// {@template social_content.document_content}
/// Social post content with document or file.
/// {@endtemplate}
abstract class IDocumentContent implements ISocialContent {}

/// {@macro social_content.social_content}
@immutable
abstract class SocialContent implements ISocialContent {
  /// {@macro social_content.social_content}
  const SocialContent();

  /// {@macro social_content.text_content}
  factory SocialContent.text(String text) = _TextContentImpl.text;
}

class _TextContentImpl extends SocialContent implements ITextContent {
  _TextContentImpl.text(String text) : data = TextContentData.text(text);

  @override
  final ITextContentData data;

  @override
  String get textOrNull => data.text;

  @override
  T maybeMap<T extends Object?>({
    required T Function() orElse,
    T Function(ITextContent content)? text,
    T Function(IPhotoContent content)? photo,
    T Function(IDocumentContent content)? document,
  }) =>
      text?.call(this) ?? orElse();

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _TextContentImpl && data == other.data;
}
