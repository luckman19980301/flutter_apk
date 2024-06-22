import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
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
  List<UserModel>? users = [];
  String _errorMessage = '';

  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();

  @override
  void initState(){
    super.initState();
    getCurrentUser();
    getUsers();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = CURRENT_USER;
      final userId = user?.uid;
      final databaseResponse = await _databaseService.getUser(userId.toString());

      if(databaseResponse.success == false){
        setState(() {
          loggedInUser = user;
          currentUserData = null;
          _errorMessage = "Error retrieving user data, try again.";
        });
      }

      setState(() {
        loggedInUser = user;
        currentUserData = databaseResponse.data;
      });

    } catch (err) {
      print(err);
      setState(() {
        loggedInUser = null;
      });
    }
  }

  Future<void> getUsers() async {
    try {
      final serviceResponse = await _databaseService.getAllUsers();

      if (serviceResponse.success == true) {
        setState(() {
          users = serviceResponse.data;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch users: ${serviceResponse.message}";
        });
      }
    } catch (err) {
      // Handle exceptions
      print("Error fetching users: $err");
      setState(() {
        _errorMessage = "Error fetching users: $err";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppHeader(title: "Chat - Home"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentUserData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserProfileButton(user: currentUserData!),
              ),
            if (users != null && users!.isNotEmpty)
              ...users!.map((user) => Container(
                color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: UserProfileButton(user: user, backgroundColor: Colors.white),                ),
              )),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: getUsers,
                child: const Text('Get Users'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class UserProfileButton extends StatelessWidget {
  const UserProfileButton({Key? key, required this.user, this.backgroundColor});

  final UserModel user;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print(user.Username);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.all(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.ProfilePictureUrl),
          ),
          const SizedBox(width: 10),
          Text(
            user.Username,
            style: const TextStyle(fontSize: 30),
          ),
        ],
      ),
    );
  }
}