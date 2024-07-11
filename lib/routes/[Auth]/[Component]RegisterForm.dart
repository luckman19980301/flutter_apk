import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/ErrorMessageWidget.dart';
import 'package:meet_chat/components/forms/UserImagePicker.dart';
import 'package:meet_chat/components/forms/GenderSelectionInputButton.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/core/services/StorageService.dart';
import 'package:meet_chat/routes/HomePage.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  Gender _selectedGender = Gender.Male;
  String _errorMessage = '';
  bool isUploading = false;
  DateTime? _selectedDateOfBirth;

  void _pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  bool _isValidAge(DateTime dateOfBirth) {
    final currentDate = DateTime.now();
    final age = currentDate.year - dateOfBirth.year;
    final isBeforeBirthday = (currentDate.month < dateOfBirth.month) ||
        (currentDate.month == dateOfBirth.month && currentDate.day < dateOfBirth.day);

    return age > 18 || (age == 18 && !isBeforeBirthday);
  }

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
    if (_selectedDateOfBirth == null) {
      setState(() {
        _errorMessage = 'Please select your date of birth.';
      });
      return;
    }
    if (!_isValidAge(_selectedDateOfBirth!)) {
      setState(() {
        _errorMessage = 'You must be at least 18 years old to register.';
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
      String aboutMe = _aboutMeController.value.text;
      String firstName = _firstNameController.value.text;
      String lastName = _lastNameController.value.text;

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
        _selectedImage!,
        userId,
        DateTime.now().millisecondsSinceEpoch.toString(),
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
        AboutMe: aboutMe,
        DateOfBirth: _selectedDateOfBirth,
        FirstName: firstName,
        LastName: lastName,
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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _firstNameController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _lastNameController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
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
            TextFormField(
              controller: _aboutMeController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'About Me',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some information about yourself.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickDateOfBirth(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDateOfBirth == null
                          ? 'Select Date of Birth'
                          : DateFormat('dd.MM.yyyy').format(_selectedDateOfBirth!),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GenderSelectionRow(
              selectedGenders: [_selectedGender],
              onGendersSelected: (selectedGenders) {
                setState(() {
                  _selectedGender = selectedGenders.first;
                });
              },
              allowMultipleSelection: false, // Single selection for registration
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
                  'Create account',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            ErrorMessageWidget(message: _errorMessage, type: MessageType.error),
          ],
        ),
      ),
    );
  }
}
