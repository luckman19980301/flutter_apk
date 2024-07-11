import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/ErrorMessageWidget.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/routes/HomePage.dart';

class LoginForm extends StatefulWidget {
  final IAuthenticationService authenticationService;
  final IDatabaseService databaseService;
  const LoginForm({super.key, required this.authenticationService, required this.databaseService});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _errorMessage = '';
  bool isLoading = false;

  void onSubmit() async {
    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      setState(() {
        _errorMessage = 'Please fill out all fields correctly.';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      isLoading = true;
    });

    try {
      String email = _emailController.value.text;
      String password = _passwordController.value.text;

      ServiceResponse<UserCredential> response =
      await widget.authenticationService.login(email, password);

      if (response.success == true) {
        final databaseResponse = await widget.databaseService.getUser(FIREBASE_INSTANCE.currentUser!.uid);
        if (databaseResponse.success == true) {
          await FIREBASE_INSTANCE.currentUser?.updateDisplayName(databaseResponse.data?.Username);
          await FIREBASE_INSTANCE.currentUser?.updatePhotoURL(databaseResponse.data?.ProfilePictureUrl);

          Navigator.pushNamed(context, HomePage.route);
        } else {
          setState(() {
            _errorMessage = databaseResponse.message ?? "Error loading user data";
          });
        }
      } else {
        setState(() {
          _errorMessage = response.message.toString();
        });
      }
    } on FirebaseAuthException catch (err) {
      setState(() {
        _errorMessage = err.message.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(
              hintText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains("@")) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.none,
            obscureText: true,
            obscuringCharacter: "#",
            decoration: InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid password.';
              } else if (value.length < 6) {
                return 'Password must be longer than 6 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          if (isLoading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
          ],
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF5F6D), Colors.pinkAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign in',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          ErrorMessageWidget(message: _errorMessage, type: MessageType.error),
        ],
      ),
    );
  }
}