import 'dart:async' show Future, Timer;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/components/AppIcon.dart';
import 'package:meet_chat/components/BottomAppBarComponent.dart';
import 'package:meet_chat/components/ErrorMessageWidget.dart';
import 'package:meet_chat/components/UserCard.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/routes/SwipePage.dart';
import 'package:meet_chat/routes/UserProfile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _usernameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<UserModel> _searchResults = [];
  String _errorMessage = '';
  bool _isLoading = false;
  Timer? _debounce;

  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_usernameController.text.isNotEmpty) {
        _searchUsers();
      } else {
        setState(() {
          _searchResults = [];
          _errorMessage = '';
        });
      }
    });
  }

  Future<void> _searchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _databaseService.searchUsers(
        username: _usernameController.text,
      );

      if (response.success == true && response.data!.isNotEmpty) {
        setState(() {
          _searchResults = response.data!;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _searchResults = [];
          _errorMessage = response.message ?? "No users found";
        });
      }
    } catch (err) {
      setState(() {
        _searchResults = [];
        _errorMessage = "Error occurred during search: $err";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.removeListener(_onSearchChanged);
    _usernameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppHeader(
        title: FIREBASE_INSTANCE.currentUser?.displayName ?? 'Chat - Home',
      ),
      bottomNavigationBar: BottomAppBarComponent(
        buttons: [
          buildIconButton(
            icon: Icons.person,
            startColor: Color.fromRGBO(43, 217, 254, 1.0),
            endColor: Colors.lightBlueAccent,
            onPressed: () {
              Navigator.pushNamed(context, UserProfile.route, arguments: FIREBASE_INSTANCE.currentUser?.uid);
            },
          ),
          buildIconButton(
            icon: Icons.home,
            startColor: const Color.fromRGBO(43, 217, 254, 1.0),
            endColor: Colors.lightBlueAccent,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          buildIconButton(
            icon: Icons.people,
            startColor: Color(0xFFFF5F6D),
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
      body: Container(
        color: const Color(0xFFF0F0F0), // Darker white background color
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        labelText: 'Search Username',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 15.0),
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_searchResults.isEmpty &&
                    !_isLoading &&
                    _errorMessage.isEmpty)
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const AppIcon(
                          size: 50.0,
                          color: Colors.pinkAccent,
                          title: 'User Search',
                          horizontal: true,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (_errorMessage.isNotEmpty && _searchResults.isEmpty)
                  Expanded(
                    child: Center(
                      child: ErrorMessageWidget(
                          message: _errorMessage, type: MessageType.warning),
                    ),
                  ),
                if (!_isLoading &&
                    _errorMessage.isEmpty &&
                    _searchResults.isNotEmpty)
                  Expanded(child: _buildMatchesTab())
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesTab() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return UserCard(user: user);
      },
    );
  }
}
