import 'package:flutter/material.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/components/UserCard.dart';
import 'package:meet_chat/components/forms/GenderSelectionInputButton.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _usernameController = TextEditingController();
  List<Gender> _selectedGenders = [];
  RangeValues _ageRange = const RangeValues(18, 100);
  List<UserModel> _searchResults = [];
  String _errorMessage = '';
  bool _isLoading = false;

  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();

  Future<void> _searchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _databaseService.searchUsers(
        username: _usernameController.text,
        genders: _selectedGenders,
        minAge: _ageRange.start.toInt(),
        maxAge: _ageRange.end.toInt(),
      );

      if (response.success == true) {
        setState(() {
          _searchResults = response.data!;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? "Error occurred during search";
        });
      }
    } catch (err) {
      setState(() {
        _errorMessage = "Error occurred during search: $err";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppHeader(
        title: CURRENT_USER?.displayName ?? 'Chat - Home',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GenderSelectionRow(
                      size: 50.0,
                      selectedGenders: _selectedGenders,
                      onGendersSelected: (selectedGenders) {
                        setState(() {
                          _selectedGenders = selectedGenders;
                        });
                      },
                      allowMultipleSelection: true, // Allow multiple selection
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}',
                style: const TextStyle(fontSize: 16),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.pinkAccent,
                  inactiveTrackColor: Colors.pinkAccent.withOpacity(0.3),
                  trackShape: const RoundedRectSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  thumbColor: Colors.pinkAccent,
                  overlayColor: Colors.pinkAccent.withAlpha(32),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
                  tickMarkShape: const RoundSliderTickMarkShape(),
                  activeTickMarkColor: Colors.pinkAccent,
                  inactiveTickMarkColor: Colors.pinkAccent.withOpacity(0.3),
                  valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.pinkAccent,
                  valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: RangeSlider(
                  values: _ageRange,
                  min: 18,
                  max: 100,
                  divisions: 82,
                  labels: RangeLabels(
                    '${_ageRange.start.round()}',
                    '${_ageRange.end.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _ageRange = values;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF5F6D), Colors.pinkAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: ElevatedButton(
                  onPressed: _searchUsers,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
              if (_errorMessage.isNotEmpty)
                Center(child: Text(_errorMessage)),
              if (!_isLoading && _errorMessage.isEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return UserCard(user: user);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
