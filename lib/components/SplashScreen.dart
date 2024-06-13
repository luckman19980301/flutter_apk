import 'package:flutter/material.dart';

import 'AppHeader.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: const AppHeader(title: "Chat - Sign in"),
      body: const Center(
        child: Text("Loading ..."),
      ),
    );
  }
}
