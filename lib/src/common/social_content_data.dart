import 'dart:typed_data';

import 'package:meta/meta.dart';

/// {@template social_content.social_content_data}
/// Data of social post content.
/// {@endtemplate}
abstract class ISocialContentData {}

/// {@template social_content.text_content_data}
/// Data of text content
/// {@endtemplate}
abstract class ITextContentData implements ISocialContentData {
  /// Text content
  abstract final String text;

  /// Content selector
  T maybeWhen<T extends Object?>({
    required T Function() orElse,
    T Function(String text)? string,
  });
}

/// {@template social_content.photo_content_data}
/// Data of photo content
/// {@endtemplate}
abstract class IPhotoContentData implements ISocialContentData {
  /// Content selector
  T maybeWhen<T extends Object?>({
    required T Function() orElse,
    T Function(Uint8List data)? bytes,
  });
}

/// {@template social_content.document_content_data}
/// Data of document content
/// {@endtemplate}
abstract class IDocumentContentData implements ISocialContentData {
  /// Content selector
  T maybeWhen<T extends Object?>({
    required T Function() orElse,
    T Function(Uint8List data)? bytes,
  });
}

/// {@template social_content_data.text_content_data}
/// Data of text content
/// {@endtemplate}
@immutable
abstract class TextContentData implements ITextContentData {
  /// {@macro social_content_data.text_content_data}
  const TextContentData();

  /// {@macro social_content_data.text_content_data}
  const factory TextContentData.text(String text) = _StringTextContentData;
}

class _StringTextContentData extends TextContentData
    implements ITextContentData {
  const _StringTextContentData(this.text);

  @override
  final String text;

  @override
  T maybeWhen<T extends Object?>({
    required T Function() orElse,
    T Function(String text)? string,
  }) =>
      string?.call(text) ?? orElse();

  @override
  int get hashCode => text.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _StringTextContentData && text == other.text;
}
