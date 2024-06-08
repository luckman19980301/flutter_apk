import 'package:chat_app/routes/HomePage.dart';
import 'package:chat_app/routes/RootPage.dart';
import 'package:chat_app/routes/SignInPage.dart';
import 'package:chat_app/routes/SignUpPage.dart';
import 'package:flutter/material.dart';

import 'constants/ThemeSchema.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeSchema,
      initialRoute: RootPage.route,
      routes: {
        HomePage.route: (context) => const HomePage(),
        SignInPage.route: (context) => const SignInPage(),
        SignUpPage.route: (context) => const SignUpPage(),
        RootPage.route: (context) => const RootPage()
      },
    );
  }
}
