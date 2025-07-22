import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

final isLoggedInProvider = StateProvider<bool>((ref) => false);

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  void setUser(String email) {
    state = state.copyWith(email: email, isLoggedIn: true);
  }

  void logout() {
    state = const UserState();
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
