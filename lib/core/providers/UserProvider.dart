import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';

class UserProvider extends ChangeNotifier {
  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();
  UserModel? _currentUserData;
  List<UserModel> _users = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  String _errorMessage = '';

  UserModel? get currentUserData => _currentUserData;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get errorMessage => _errorMessage;

  Future<void> getCurrentUser(String userId) async {
    try {
      final databaseResponse = await _databaseService.getUser(userId);
      if (databaseResponse.success == true) {
        _currentUserData = databaseResponse.data;
      } else {
        _errorMessage = "Error retrieving user data, try again.";
      }
    } catch (err) {
      _errorMessage = "Error: $err";
    }
    notifyListeners();
  }

  Future<void> getUsers() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    try {
      final serviceResponse = await _databaseService.getAllUsers(limit: 10, lastDocument: _lastDocument);
      if (serviceResponse.success == true) {
        final fetchedUsers = serviceResponse.data!;
        _users.addAll(fetchedUsers);
        if (fetchedUsers.length < 10) {
          _hasMore = false;
        } else {
          _lastDocument = fetchedUsers.isNotEmpty ? fetchedUsers.last.documentSnapshot : null;
        }
      } else {
        _errorMessage = "${serviceResponse.message}";
      }
    } catch (err) {
      _errorMessage = "Error fetching users: $err";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
