import 'package:flutter/material.dart';
import 'package:meet_chat/components/AppIcon.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/core/services/StorageService.dart';
import 'package:meet_chat/routes/%5BAuth%5D/%5BComponent%5DLoginForm.dart';
import 'package:meet_chat/routes/%5BAuth%5D/%5BComponent%5DRegisterForm.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.loginMode});

  static const String loginRoute = "auth_login";
  static const String registerRoute = "auth_register";

  final bool loginMode;

  @override
  Widget build(BuildContext context) {
    final IAuthenticationService authenticationService =
    INJECTOR<IAuthenticationService>();
    final IStorageService storageService = INJECTOR<IStorageService>();
    final IDatabaseService databaseService = INJECTOR<IDatabaseService>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            AppIcon(
              size: 50.0,
              color: Colors.pinkAccent,
              title: loginMode ? "Timber - Sign in" : "Timber - Register",
            ),
            const SizedBox(height: 20),
            if (loginMode)
              LoginForm(
                authenticationService: authenticationService,
                databaseService: databaseService,
              )
            else
              RegisterForm(
                authenticationService: authenticationService,
                storageService: storageService,
                databaseService: databaseService,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loginMode
                      ? "Don't have an account?"
                      : "Already have an account?",
                  style: const TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    if (loginMode) {
                      Navigator.pushReplacementNamed(
                          context, AuthPage.registerRoute);
                    } else {
                      Navigator.pushReplacementNamed(
                          context, AuthPage.loginRoute);
                    }
                  },
                  child: Text(
                    loginMode ? "Create an account" : "Sign in",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}