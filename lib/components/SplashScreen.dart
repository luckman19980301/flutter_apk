import 'package:flutter/material.dart';

import 'AppHeader.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: "Chat - Sign in"),
      body: const Center(
        child: Text("Loading ..."),
      ),
    );
  }
}
