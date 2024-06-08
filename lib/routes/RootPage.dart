import 'package:chat_app/components/AppHeader.dart';
import 'package:chat_app/components/AppIcon.dart';
import 'package:chat_app/components/Modal.dart';
import 'package:chat_app/routes/SignInPage.dart';
import 'package:chat_app/routes/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  static const String route = "root";

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Chat - Create profile"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(size: 100.0),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, SignInPage.route);
                  },
                  child: const Text("Sign in"),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, SignUpPage.route);
                  },
                  child: const Text("Create account"),
                ),
                const SizedBox(height: 10.0),
                const Modal(
                  icon: FontAwesomeIcons.circleInfo,
                  buttonTitle: "About",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
