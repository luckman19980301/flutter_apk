import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/routes/UserProfile.dart';

import '../components/AppHeader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String route = "home";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late User? loggedInUser;
  UserModel? currentUserData;
  List<UserModel> users = [];
  String _errorMessage = '';
  bool isLoading = false;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;

  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getCurrentUser();
    getUsers();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = CURRENT_USER;
      final userId = user?.uid;
      final databaseResponse = await _databaseService.getUser(userId.toString());

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
          limit: 10, lastDocument: lastDocument);

      if (serviceResponse.success == true) {
        final fetchedUsers = serviceResponse.data as List<UserModel>;
        setState(() {
          users.addAll(fetchedUsers);
          if (fetchedUsers.length < 10) {
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
      appBar: AppHeader(
        title: currentUserData?.Username ?? 'Chat - Home',
        tabController: _tabController,
        tabs: const [
          Tab(text: 'Matches'),
          Tab(text: 'Messages'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMatchesTab(),
                  Center(child: Text('Messages')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,  // Increased height of the card
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: users.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == users.length) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: getUsers,
                      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15
                          ),
                        ),
                      ),
                      child: const Text('Load more users'),
                    ),
                  );
                }
                final user = users[index];
                return UserProfileCard(user: user);
              },
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({Key? key, required this.user}) : super(key: key);

  final UserModel user;

  Color backgroundImageColor() {
    return user.UserGender == Gender.Male ? Colors.blueAccent : Colors.pinkAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, UserProfile.route, arguments: user.Id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(user.ProfilePictureUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            user.Username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (user.Age != null)
                    Text(
                      '${user.Age} years',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  Icon(
                    Icons.favorite,
                    color: user.UserGender == Gender.Male ? Colors.blueAccent : Colors.pinkAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
