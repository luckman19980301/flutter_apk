import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/AppHeader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String route = "home";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authenticationProvider = FirebaseAuth.instance;

  late User loggedInUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _authenticationProvider.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const AppHeader(title: "Chat - Sign in"),
      body: Column(
        children: [
          Text("Logged in")
        ],
      ),
    );
  }
}
