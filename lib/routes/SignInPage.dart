import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/components/AppIcon.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/routes/SignUpPage.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  static const String route = "sign_in";

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String _errorMessage = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final IAuthenticationService _authenticationService =
      injector<IAuthenticationService>();

  void onSubmit() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      var email = _emailController.value.text;
      var password = _passwordController.value.text;
      var response = await _authenticationService.login(email, password);

      var user = response.data;

      if (user == null) {
        setState(() {
          _errorMessage = response.message.toString();
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(response.message.toString() ?? 'Authentication failed')));
      }

      if (user != null) {
        Navigator.pushNamed(context, HomePage.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const AppHeader(title: "Chat - Sign in"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppIcon(size: 50.0),
                  Text(
                    "Sign into your account",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onSubmit,
                    child: const Text("Sign in"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Don't have an account?"),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignUpPage.route);
                    },
                    child: const Text("Create account"),
                  ),
                ],
              ),
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(top: 30),
                  color: Colors.redAccent,
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
