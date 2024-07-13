import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserState {
  final String? profilePictureUrl;
  final String? username;

  UserState({this.profilePictureUrl, this.username});

  UserState copyWith({String? profilePictureUrl, String? username}) {
    return UserState(
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      username: username ?? this.username,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  void setProfilePictureUrl(String? url) {
    state = state.copyWith(profilePictureUrl: url);
  }

  void setUsername(String? username) {
    state = state.copyWith(username: username);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
