import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (String result) {
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
            PopupMenuItem<String>(
              value: 'Logout',
              child: IconButton(
                icon: const Icon(
                  Icons.exit_to_app
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}