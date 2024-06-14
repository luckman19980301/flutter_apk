import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/routes/SignInPage.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, required this.title});

  final String title;

  void _logout(BuildContext context) async {
    final user = await FIREBASE_INSTANCE.currentUser;
    if (user != null) {
      print("LOGGED IN USER EMAIL: ${user.email}");
    }
    final response = await injector<IAuthenticationService>().logout();
    if (response.message == "Signed out successfully") {
      Navigator.pushReplacementNamed(context, SignInPage.route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'Logout') {
              _logout(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Option 1',
              child: Text('Option 1'),
            ),
            const PopupMenuItem<String>(
              value: 'Option 2',
              child: Text('Option 2'),
            ),
            const PopupMenuItem<String>(
              value: 'Logout',
              child: Text('Logout'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}