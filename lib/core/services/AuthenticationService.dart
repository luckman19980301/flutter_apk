import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException, UserCredential;
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/ErrorMessages.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';

abstract class IAuthenticationService {
  Future<ServiceResponse<UserCredential>> registerAccount(String email, String password);

  Future<ServiceResponse<UserCredential>> login(String email, String password);

  Future<ServiceResponse<String>> logout();
}

class AuthenticationService implements IAuthenticationService {

  @override
  Future<ServiceResponse<UserCredential>> login(String email, String password) async {
    try {
      final user = await FIREBASE_INSTANCE.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return ServiceResponse<UserCredential>(message: "Login successful", data: user);
    } on FirebaseAuthException catch (err) {
      String errorMessage = ErrorMessages.getErrorMessage(err.code);
      return ServiceResponse<UserCredential>(message: errorMessage);
    }
  }

  @override
  Future<ServiceResponse<String>> logout() async{
    try {
      await FIREBASE_INSTANCE.signOut();
      return ServiceResponse<String>(message: "Signed out successfully");
    } catch (err) {
      return ServiceResponse<String>(message: "An error occurred during logout");
    }
  }

  @override
  Future<ServiceResponse<UserCredential>> registerAccount(
      String email, String password) async {
    try {
      var response = await FIREBASE_INSTANCE.createUserWithEmailAndPassword(
          email: email, password: password);
      return ServiceResponse<UserCredential>(data: response,message: "New account created");
    } on FirebaseAuthException catch (err) {
      String errorMessage = ErrorMessages.getErrorMessage(err.code);
      return ServiceResponse<UserCredential>(message: errorMessage);
    }
  }
}
