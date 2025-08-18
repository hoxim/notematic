import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

final isLoggedInProvider = StateProvider<bool>((ref) => false);

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;
  UserNotifier(this.ref) : super(const UserState());

  void setUser(String email) {
    state = state.copyWith(email: email, isLoggedIn: true);
  }

  void logout() {
    state = const UserState();
  }

  /// Complete logout that clears tokens and updates login state
  Future<void> completeLogout() async {
    // Clear tokens
    final tokenService = TokenService();
    await tokenService.clearToken();
    
    // Update user state
    state = const UserState();
    
    // Update login state
    ref.read(isLoggedInProvider.notifier).state = false;
  }

  void setLoginState(bool isLoggedIn) {
    state = state.copyWith(isLoggedIn: isLoggedIn);
  }
}

class UserState {
  final String email;
  final bool isLoggedIn;

  const UserState({
    this.email = '',
    this.isLoggedIn = false,
  });

  UserState copyWith({
    String? email,
    bool? isLoggedIn,
  }) {
    return UserState(
      email: email ?? this.email,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
