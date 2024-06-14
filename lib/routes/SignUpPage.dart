import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/routes/HomePage.dart';
import 'package:meet_chat/routes/SignInPage.dart';
import '../components/AppHeader.dart' show AppHeader;
import 'package:meet_chat/components/AppIcon.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const String route = "sign_up";

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _errorMessage = '';

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final IAuthenticationService _authenticationService =
      injector<IAuthenticationService>();

  void onSubmit() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      if (_passwordController.text != _repeatPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
      } else {
        var email = _emailController.value.text;
        var password = _passwordController.value.text;
        var response =
            await _authenticationService.registerAccount(email, password);

        var newUser = response.data;
        if (newUser == null) {
          setState(() {
            _errorMessage = response.message.toString();
          });
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(response.message ?? 'Authentication failed')));
        }
        if (newUser != null) {
          Navigator.pushNamed(context, HomePage.route);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const AppHeader(title: "Chat - Create profile"),
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
                    "Create new account",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.name,
                controller: _firstnameController,
                decoration: const InputDecoration(hintText: 'Firstname'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your firstname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.name,
                controller: _lastnameController,
                decoration: const InputDecoration(hintText: 'Lastname'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your lastname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                obscuringCharacter: "#",
                controller: _passwordController,
                decoration: const InputDecoration(hintText: 'Password'),
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _repeatPasswordController,
                decoration: const InputDecoration(hintText: 'Repeat password'),
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please repeat your password';
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
                    child: const Text("Create account"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Already have an account?"),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignInPage.route);
                    },
                    child: const Text("Sign in"),
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
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
