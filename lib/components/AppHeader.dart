import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/routes/%5BAuth%5D/AuthPage.dart';
import 'package:meet_chat/routes/SearchPage.dart'; // Import the SearchPage

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final TabController? tabController;
  final List<Widget>? tabs;

  const AppHeader({
    super.key,
    required this.title,
    this.tabController,
    this.tabs,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (tabController != null ? kTextTabBarHeight : 0.0));
}

class _AppHeaderState extends State<AppHeader> {
  late User? user = FIREBASE_INSTANCE.currentUser;

  void _logout(BuildContext context) async {
    print("signed as: ${FIREBASE_INSTANCE.currentUser?.displayName}");
    await FIREBASE_INSTANCE.signOut();

    setState(() {
      user = null;
    });
    print("LOGGED: ${FIREBASE_INSTANCE.currentUser?.displayName}");

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage(loginMode: true)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF5F6D), Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          if (user != null && user!.photoURL != null)
            CircleAvatar(
              backgroundImage: NetworkImage(user!.photoURL!),
            ),
          const SizedBox(width: 10),
          if (user != null)
            Text(
              user!.displayName ?? "User",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
        ],
      ),
      bottom: (widget.tabController != null && widget.tabs != null)
          ? TabBar(
        indicatorColor: Colors.amberAccent,
        controller: widget.tabController,
        tabs: widget.tabs!,
      )
          : null,
      actions: <Widget>[
        if (user != null)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        IconButton(
          icon: const Icon(Icons.shopping_bag, color: Colors.white),
          onPressed: () {
            // Handle shopping bag action
          },
        ),
        IconButton(
          icon: const Icon(Icons.security, color: Colors.white),
          onPressed: () {
            // Handle security action
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
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

            if (user != null) {
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
