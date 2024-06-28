import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_chat/components/forms/RedirectButtonWithImage.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';

class UserProfile extends StatefulWidget {
  static const String route = "profile";

  final String userId;

  const UserProfile({super.key, required this.userId});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  UserModel? user;
  bool isLoading = true;
  String errorMessage = '';

  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final databaseResponse = await _databaseService.getUser(widget.userId);
      if (databaseResponse.success == true) {
        setState(() {
          user = databaseResponse.data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = databaseResponse.message ?? "Error loading user data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading user data: $e";
        isLoading = false;
      });
    }
  }

  Color _getBackgroundColor() {
    return user?.UserGender == Gender.Male
        ? Colors.blueAccent
        : Colors.pinkAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        bottom: isLoading || errorMessage.isNotEmpty
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "User Information"),
                  Tab(text: "Friends"),
                  Tab(text: "Settings"),
                ],
              ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(
                  children: [
                    Container(
                      color: _getBackgroundColor(),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RedirectButtonWithImage(
                            icon: user?.UserGender == Gender.Male
                                ? Icons.male
                                : Icons.female,
                            text: '${user!.Age} years',
                            size: 30,
                          ),
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(user!.ProfilePictureUrl),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user!.Username,
                                style: const TextStyle(
                                    fontSize: 24, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user!.Email,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                          RedirectButtonWithImage(
                            icon: FontAwesomeIcons.userPlus,
                            text: "Add friend",
                            onPressed: () {
                              // Add friend request logic here
                            },
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUserInformation(),
                          _buildFriendsList(),
                          _buildSettings(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildUserInformation() {
    return Center(
      child: Text("Additional user information goes here."),
    );
  }

  Widget _buildFriendsList() {
    // Dummy friends list for demonstration. Replace with actual data.
    final friends = ["Friend 1", "Friend 2", "Friend 3"];
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(friends[index]),
        );
      },
    );
  }

  Widget _buildSettings() {
    return Center(
      child: Text("Settings go here."),
    );
  }
}
