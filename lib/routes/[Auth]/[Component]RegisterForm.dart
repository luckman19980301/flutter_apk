
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/forms/UserImagePicker.dart';
import 'package:meet_chat/components/forms/GenderSelectionInputButton.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/core/services/StorageService.dart';
import 'package:meet_chat/routes/HomePage.dart';

class RegisterForm extends StatefulWidget {
  final IAuthenticationService authenticationService;
  final IStorageService storageService;
  final IDatabaseService databaseService;

  const RegisterForm({
    super.key,
    required this.authenticationService,
    required this.storageService,
    required this.databaseService,
  });

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  Gender _selectedGender = Gender.Male;
  String _errorMessage = '';
  bool isUploading = false;

  void onSubmit() async {
    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      setState(() {
        _errorMessage = 'Please fill out all fields correctly.';
      });
      return;
    }
    if (_passwordController.text != _repeatPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Please select a profile picture.';
      });
      return;
    }

    try {
      setState(() {
        isUploading = true;
      });
      String email = _emailController.value.text;
      String password = _passwordController.value.text;
      String username = _userNameController.value.text;

      ServiceResponse<UserCredential> authResponse =
      await widget.authenticationService.registerAccount(email, password);
      String userId = authResponse.data?.user?.uid ?? '';
      if (userId.isEmpty || authResponse.success == false) {
        setState(() {
          _errorMessage = authResponse.message.toString();
          isUploading = false;
        });
        return;
      }

      ServiceResponse<String> storageResponse = await widget.storageService.uploadFile(
        _selectedImage,
        "${userId}_profilePicture",
        "user_images",
      );
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
        Email: email,
      );
      ServiceResponse<bool> databaseResponse =
      await widget.databaseService.createUser(userId, newUser);
      if (databaseResponse.success == false) {
        setState(() {
          _errorMessage = databaseResponse.message.toString();
          isUploading = false;
        });
        return;
      }

      // Update the user profile in Firebase Authentication
      User? user = authResponse.data?.user;
      await user?.updateDisplayName(username);
      await user?.updatePhotoURL(storageResponse.data.toString());

      if (authResponse.success == true &&
          databaseResponse.success == true &&
          storageResponse.success == true) {
        Navigator.pushNamed(context, HomePage.route);
      } else {
        setState(() {
          _errorMessage = "An error occurred. Please try again.";
          isUploading = false;
        });
      }
    } on FirebaseAuthException catch (err) {
      setState(() {
        _errorMessage = err.message.toString();
        isUploading = false;
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
            controller: _userNameController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(
              hintText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid username.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          TextFormField(
            controller: _repeatPasswordController,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.none,
            obscureText: true,
            obscuringCharacter: "#",
            decoration: InputDecoration(
              hintText: 'Repeat Password',
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
          ),
          const SizedBox(height: 20),
          if (isUploading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
          ],
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Create account',
              style: TextStyle(fontSize: 18),
            ),
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
    );
  }
}