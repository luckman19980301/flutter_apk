import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/routes/AuthPage.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  AppHeader({super.key, required this.title});

  final String title;
  late User? user = FIREBASE_INSTANCE.currentUser;

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppHeaderState extends State<AppHeader> {

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage(loginMode: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'Logout') {
              _logout(context);
            }
          },
          itemBuilder: (BuildContext context) {
            List<PopupMenuEntry<String>> menuItems = [
              const PopupMenuItem<String>(
                value: 'Option 1',
                child: Text('Option 1'),
              ),
              const PopupMenuItem<String>(
                value: 'Option 2',
                child: Text('Option 2'),
              ),
            ];

            if (widget.user != null) {
              menuItems.add(
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              );
            }

            return menuItems;
          },
        ),
      ],
    );
  }


}