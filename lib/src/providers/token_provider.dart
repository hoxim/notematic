import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_service.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});
