import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/SplashScreen.dart';
import 'package:meet_chat/core/dependencies.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/firebase_options.dart';
import 'package:meet_chat/routes/AuthPage.dart';
import 'package:meet_chat/routes/HomePage.dart';
import 'package:meet_chat/routes/RootPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meet_chat/routes/UserProfile.dart';

import 'constants/ThemeSchema.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeSchema,
      initialRoute: FIREBASE_INSTANCE.currentUser != null ? HomePage.route : RootPage.route,
      routes: {
        HomePage.route: (context) => const HomePage(),
        AuthPage.loginRoute: (context) => const AuthPage(loginMode: true),
        AuthPage.registerRoute: (context) => const AuthPage(loginMode: false),
        RootPage.route: (context) => const RootPage(),
        UserProfile.route: (context) => const UserProfile(),
      },
    );
  }
}