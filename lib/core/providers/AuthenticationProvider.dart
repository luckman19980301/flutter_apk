import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';

final authenticationProvider = StateNotifierProvider<AuthenticationNotifier, User?>((ref) {
  return AuthenticationNotifier();
});

class AuthenticationNotifier extends StateNotifier<User?> {
  final IAuthenticationService _authService = INJECTOR<IAuthenticationService>();

  AuthenticationNotifier() : super(FIREBASE_INSTANCE.currentUser);

  Future<ServiceResponse<UserCredential>> login(String email, String password) async {
    var response = await _authService.login(email, password);
    state = FIREBASE_INSTANCE.currentUser;
    return response;
  }

  Future<ServiceResponse<UserCredential>> register(String email, String password) async {
    var response = await _authService.registerAccount(email, password);
    state = FIREBASE_INSTANCE.currentUser;
    return response;
  }

  Future<ServiceResponse<String>> logout() async {
    var response = await _authService.logout();
    state = FIREBASE_INSTANCE.currentUser;
    return response;
  }
}