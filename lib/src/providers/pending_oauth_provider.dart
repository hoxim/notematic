import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingOAuthLinkData {
  final String email;
  final String provider;
  final String oauthToken;
  final Map<String, dynamic>? oauthData;

  const PendingOAuthLinkData({
    required this.email,
    required this.provider,
    required this.oauthToken,
    this.oauthData,
  });
}

final pendingOAuthLinkProvider =
    StateProvider<PendingOAuthLinkData?>((ref) => null);
