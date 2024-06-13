import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/SplashScreen.dart';
import 'package:meet_chat/firebase_options.dart';
import 'package:meet_chat/routes/HomePage.dart';
import 'package:meet_chat/routes/RootPage.dart';
import 'package:meet_chat/routes/SignInPage.dart';
import 'package:meet_chat/routes/SignUpPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'constants/ThemeSchema.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
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
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Splashscreen();
          }

          if(snapshot.hasData){
            return const HomePage();
          }
          return const RootPage();
        },
      ),
    );
  }
}
