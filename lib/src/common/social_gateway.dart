import 'package:crosspost/src/common/social_post.dart';

/// {@template social_gateway.social_gateway}
/// Using for social network services
/// {@endtemplate}
abstract class ISocialGateway {
  /// Validate post
  bool validate();

  /// Send post to social network
  void send(ISocialPost post);
}

/// {@macro social_gateway.social_gateway}
abstract class SocialGateway implements ISocialGateway {
  /// {@macro social_gateway.social_gateway}
  const SocialGateway();
}
