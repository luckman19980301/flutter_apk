import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/components/AppIcon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/forms/UserImagePicker.dart';
import 'package:meet_chat/components/forms/GenderSelectionInputButton.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/core/services/StorageService.dart';
import 'package:meet_chat/routes/HomePage.dart';
import 'package:meet_chat/routes/UserProfile.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.loginMode});

  static const String loginRoute = "auth_login";
  static const String registerRoute = "auth_register";

  final bool loginMode;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  late bool isUploading = false;
  Gender _selectedGender = Gender.Male;

  String _errorMessage = '';

  String get submitButtonText =>
      widget.loginMode ? "Sign in" : "Create account";

  String get titlePageText =>
      widget.loginMode ? "Sign into your account" : "Create an account";

  String get redirectButtonLabelText => widget.loginMode
      ? "Don't have an account ?"
      : "Already have an account ?";

  String get redirectButtonText =>
      widget.loginMode ? "Create an account" : "Sign in";

  final IAuthenticationService _authenticationService =
      INJECTOR<IAuthenticationService>();
  final IStorageService _storageService = INJECTOR<IStorageService>();
  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();

  void onSubmit() async {
    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      setState(() {
        _errorMessage = 'Please fill out all fields correctly.';
      });
      return;
    }
    if (!widget.loginMode &&
        _passwordController.text != _repeatPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    } else {
      setState(() {
        _errorMessage = '';
      });
    }

    if (!widget.loginMode && _selectedImage == null) {
      setState(() {
        _errorMessage = 'Please select a profile picture.';
      });
      return;
    }

    try {
      if (widget.loginMode) {
        String email = _emailController.value.text;
        String password = _passwordController.value.text;

        ServiceResponse<UserCredential> response =
            await _authenticationService.login(email, password);
        if (response.success == true) {
          Navigator.pushNamed(context, HomePage.route);
        } else {
          setState(() {
            _errorMessage = response.message.toString();
          });
          return;
        }
      } else {
        setState(() {
          isUploading = true;
        });
        String email = _emailController.value.text;
        String password = _passwordController.value.text;
        String username = _userNameController.value.text;

        ServiceResponse<UserCredential> authResponse =
            await _authenticationService.registerAccount(email, password);
        String userId = authResponse.data?.user?.uid ?? '';
        if (userId.isEmpty || authResponse.success == false) {
          setState(() {
            _errorMessage = authResponse.message.toString();
            isUploading = false;
          });
          return;
        }

        ServiceResponse<String> storageResponse =
            await _storageService.uploadFile(
                _selectedImage, "${userId}_profilePicture", "user_images");
        if (storageResponse.success == false) {
          setState(() {
            _errorMessage = storageResponse.message.toString();
            isUploading = false;
          });
          return;
        }

        UserModel newUser = UserModel(
            Id: userId,
            Username: username,
            ProfilePictureUrl: storageResponse.data.toString(),
            UserGender: _selectedGender,
            Email: email);
        ServiceResponse<bool> databaseResponse =
            await _databaseService.createUser(userId, newUser);
        if (databaseResponse.success == false) {
          setState(() {
            _errorMessage = databaseResponse.message.toString();
            isUploading = false;
          });
          return;
        }

        if (authResponse.success == true &&
            databaseResponse.success == true &&
            storageResponse.success == true) {
          Navigator.pushNamed(context, HomePage.route);
        } else {
          setState(() {
            _errorMessage = "response.message.toString()";
            isUploading = false;
          });
          return;
        }
      }
    } on FirebaseAuthException catch (err) {
      setState(() {
        _errorMessage = err.message.toString();
        isUploading = false;
      });
    }
  }

  void _redirect() {
    if (widget.loginMode) {
      Navigator.pushReplacementNamed(context, AuthPage.registerRoute);
    } else {
      Navigator.pushReplacementNamed(context, AuthPage.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppHeader(title: "Chat - Sign in"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const AppIcon(size: 50.0),
                  Text(
                    titlePageText,
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (!widget.loginMode) ...[
                TextFormField(
                  controller: _userNameController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  decoration: const InputDecoration(hintText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid username.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(hintText: 'Email'),
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
                decoration: const InputDecoration(hintText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid password.';
                  } else if (value.length < 6) {
                    return 'Password must be longer than 6 characters.';
                  }
                  return null;
                },
              ),
              if (!widget.loginMode) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _repeatPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  obscureText: true,
                  obscuringCharacter: "#",
                  decoration:
                      const InputDecoration(hintText: 'Repeat Password'),
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
                GenderSelectionRow(
                  selectedGender: _selectedGender,
                  onGenderSelected: (Gender gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                ),
                const SizedBox(height: 20),
                UserImagePicker(
                  onPickImage: (pickedImage) {
                    setState(() {
                      _selectedImage = pickedImage;
                    });
                  },
                )
              ],
              const SizedBox(height: 20),
              if (isUploading) ...[const CircularProgressIndicator()],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onSubmit,
                    child: Text(submitButtonText),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(redirectButtonLabelText),
                  ElevatedButton(
                    onPressed: _redirect,
                    child: Text(redirectButtonText),
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