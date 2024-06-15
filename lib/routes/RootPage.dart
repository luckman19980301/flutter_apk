import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/components/AppIcon.dart';
import 'package:meet_chat/components/Modal.dart';
import 'package:meet_chat/routes/AuthPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  static const String route = "root";

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    );

    _animationController.forward();
    _animation.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(title: "Chat - Create profile"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 100,
              child: AppIcon(size: _animation.value * 100)),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AuthPage.loginRoute);
                  },
                  child: const Text("Sign in"),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context,  AuthPage.registerRoute);
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
