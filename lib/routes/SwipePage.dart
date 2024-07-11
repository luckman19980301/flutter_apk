import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/components/BottomAppBarComponent.dart';
import 'package:meet_chat/components/ErrorMessageWidget.dart';
import 'package:meet_chat/components/UserCard.dart';
import 'package:meet_chat/components/forms/GenderSelectionInputButton.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  static const String route = "swipe";

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();
  final List<UserModel> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;

  List<Gender> _selectedGenders = [];
  RangeValues _ageRange = const RangeValues(18, 60);

  @override
  void initState() {
    super.initState();
    _loadFilteredUsers();
  }

  Future<void> _loadFilteredUsers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _databaseService.searchUsers(
        genders: _selectedGenders.isEmpty ? null : _selectedGenders,
        minAge: _ageRange.start.round(),
        maxAge: _ageRange.end.round(),
      );
      if (response.success == true && response.data != null) {
        setState(() {
          _users.clear();
          _users.addAll(response.data!);
          _currentIndex = 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onSwipeRight() {
    setState(() {
      if (_currentIndex < _users.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _onSwipeLeft() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  void _onGendersSelected(List<Gender> genders) {
    setState(() {
      _selectedGenders = genders;
    });
    _loadFilteredUsers();
  }

  void _onAgeRangeChanged(RangeValues values) {
    setState(() {
      _ageRange = values;
    });
    _loadFilteredUsers();
  }

  void _showAgeRangeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        RangeValues tempRange = _ageRange;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Age Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    RangeSlider(
                      values: tempRange,
                      min: 18,
                      max: 60,
                      divisions: 42,
                      labels: RangeLabels(
                        tempRange.start.round().toString(),
                        tempRange.end.round().toString(),
                      ),
                      onChanged: (values) {
                        setState(() {
                          tempRange = values;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Min: ${tempRange.start.round()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Max: ${tempRange.end.round()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5F6D), Colors.pinkAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _ageRange = tempRange;
                          });
                          Navigator.of(context).pop();
                          _loadFilteredUsers();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: FIREBASE_INSTANCE.currentUser?.displayName ?? 'Swipe Users',
      ),
      body: Container(
        color: const Color(0xFFF0F0F0), // Darker white background color
        child: SafeArea(
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GenderSelectionRow(
                              selectedGenders: _selectedGenders,
                              onGendersSelected: _onGendersSelected,
                              allowMultipleSelection: true,
                              size: 60,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _showAgeRangeDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF5F6D), Colors.pinkAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Age: ${_ageRange.start.round()} - ${_ageRange.end.round()}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                    ? const Center(
                  child: ErrorMessageWidget(
                      message: 'Error loading users',
                      type: MessageType.error),
                )
                    : _users.isEmpty
                    ? const Center(
                  child: ErrorMessageWidget(
                      message: 'No users found',
                      type: MessageType.warning),
                )
                    : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      _onSwipeRight();
                    } else if (details.primaryVelocity! > 0) {
                      _onSwipeLeft();
                    }
                  },
                  child: UserCard(user: _users[_currentIndex]),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBarComponent(
        buttons: [
          buildIconButton(
            icon: FontAwesomeIcons.arrowLeft,
            startColor: _currentIndex > 0 ? Colors.blueAccent : Colors.grey,
            endColor: _currentIndex > 0 ? Colors.lightBlueAccent : Colors.grey,
            onPressed: _currentIndex > 0 ? _onSwipeLeft : null,
          ),
          buildIconButton(
            icon: FontAwesomeIcons.times,
            startColor: Colors.red,
            endColor: Colors.deepOrange,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          buildIconButton(
            icon: FontAwesomeIcons.userPlus,
            startColor: _users.isNotEmpty ? Colors.greenAccent : Colors.grey,
            endColor: _users.isNotEmpty ? Colors.green : Colors.grey,
            onPressed: _users.isNotEmpty ? () {
              // Add friend request logic here
            } : null,
          ),
          buildIconButton(
            icon: FontAwesomeIcons.arrowRight,
            startColor: _currentIndex < _users.length - 1 ? Colors.blueAccent : Colors.grey,
            endColor: _currentIndex < _users.length - 1 ? Colors.lightBlueAccent : Colors.grey,
            onPressed: _currentIndex < _users.length - 1 ? _onSwipeRight : null,
          ),
        ],
      ),
    );
  }
}