import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:meet_chat/components/UserProfileButton.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';

import '../components/AppHeader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String route = "home";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? loggedInUser;
  UserModel? currentUserData;
  List<UserModel> users = [];
  String _errorMessage = '';
  bool isLoading = false;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;

  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = CURRENT_USER;
      final userId = user?.uid;
      final databaseResponse =
          await _databaseService.getUser(userId.toString());

      if (databaseResponse.success == false) {
        setState(() {
          loggedInUser = user;
          currentUserData = null;
          _errorMessage = "Error retrieving user data, try again.";
        });
      } else {
        setState(() {
          loggedInUser = user;
          currentUserData = databaseResponse.data;
        });
      }
    } catch (err) {
      setState(() {
        loggedInUser = null;
      });
    }
  }

  Future<void> getUsers() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final serviceResponse = await _databaseService.getAllUsers(
          limit: 1, lastDocument: lastDocument);

      if (serviceResponse.success == true) {
        final fetchedUsers = serviceResponse.data as List<UserModel>;
        setState(() {
          users.addAll(fetchedUsers);
          if (fetchedUsers.length < 1) {
            hasMore = false;
          } else {
            lastDocument = fetchedUsers.isNotEmpty
                ? fetchedUsers.last.documentSnapshot
                : null;
          }
        });
      } else {
        setState(() {
          _errorMessage = "${serviceResponse.message}";
        });
      }
    } catch (err) {
      setState(() {
        _errorMessage = "Error fetching users: $err";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppHeader(title: "Chat - Home"),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentUserData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    UserProfileButton(
                        user: currentUserData!, isCurrentUser: true, backgroundColor: Colors.white),
                    const Divider(thickness: 2, color: Colors.blueGrey),
                  ],
                ),
              ),
            if (users.isNotEmpty)
              ...users.map((user) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserProfileButton(
                    user: user, backgroundColor: Colors.white),
              )),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (!isLoading && hasMore)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: getUsers,
                    child: const Text('Load more users'),
                  ),
                ),
              ),
            if (_errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(top: 30),
                color: Colors.redAccent,
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
