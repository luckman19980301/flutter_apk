import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_chat/components/ErrorMessageWidget.dart';
import 'package:meet_chat/components/UserCard.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/routes/SwipePage.dart';
import 'package:meet_chat/routes/UserProfile.dart';
import '../components/AppHeader.dart';
import '../components/BottomAppBarComponent.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  OverlayEntry? _currentOverlayEntry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getCurrentUser();
    getUsers();

    // Add listener to ScrollController
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        getUsers();
      }
    });
  }

  Future<void> getCurrentUser() async {
    try {
      final user = FIREBASE_INSTANCE.currentUser;
      final userId = user?.uid;
      final databaseResponse = await _databaseService.getUser(userId.toString());

      if (databaseResponse.success == false) {
        setState(() {
          loggedInUser = user;
          currentUserData = null;
          _showErrorMessage("Error retrieving user data, try again.");
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
        limit: 10, // Increase the limit
        lastDocument: lastDocument,
      );

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
          _showErrorMessage("${serviceResponse.message}");
        });
      }
    } catch (err) {
      setState(() {
        _showErrorMessage("Error fetching users: $err");
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
    }

    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 120,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: ErrorMessageWidget(
            message: message,
            type: MessageType.warning,
            canClose: true,
          ),
        ),
      ),
    );

    _currentOverlayEntry = overlayEntry;
    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (_currentOverlayEntry == overlayEntry) {
        _currentOverlayEntry?.remove();
        _currentOverlayEntry = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppHeader(
        title: currentUserData?.Username ?? 'Chat - Home',
        tabController: _tabController,
        tabs: const [
          Tab(text: 'Matches'),
          Tab(text: 'Messages'),
        ],
      ),
      body: Container(
        color: const Color(0xFFF0F0F0),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMatchesTab(),
                    const Center(child: Text('Messages')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBarComponent(
        buttons: [
          buildIconButton(
            icon: Icons.person,
            startColor: const Color.fromRGBO(43, 217, 254, 1.0),
            endColor: Colors.lightBlueAccent,
            onPressed: () {
              Navigator.pushNamed(context, UserProfile.route,
                  arguments: loggedInUser?.uid);
            },
          ),
          buildIconButton(
            icon: Icons.people,
            startColor: const Color(0xFFFF5F6D),
            endColor: Colors.pinkAccent,
            onPressed: () {
              Navigator.pushNamed(context, SwipePage.route);
            },
          ),
          buildIconButton(
            icon: Icons.settings,
            startColor: Colors.red,
            endColor: Colors.deepOrange,
            onPressed: () {
              //  Navigator.pushNamed(context, SettingsPage.route);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (users.isNotEmpty)
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4, // Increased height of the card
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserCard(user: user);
                },
              ),
            ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!isLoading) _buildLoadMoreButton(),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF5F6D), Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: ElevatedButton(
          onPressed: getUsers,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            users.isEmpty ? 'Refresh' : 'Load more users',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
