import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:meet_chat/core/models/UserModel.dart';

abstract class IDatabaseService {
  Future<ServiceResponse<bool>> createUser(String id, UserModel user);
  Future<ServiceResponse<UserModel>> getUser(String id);
  Future<ServiceResponse<List<UserModel>>> getAllUsers({int limit, DocumentSnapshot? lastDocument});
  Future<ServiceResponse<List<UserModel>>> getFriends();
}

class DatabaseService implements IDatabaseService {
  @override
  Future<ServiceResponse<bool>> createUser(String id, UserModel user) async {
    try {
      await FIREBASE_FIRESTORE.collection("users").doc(id).set({
        "username": user.Username,
        "firstName": user.FirstName,
        "lastName": user.LastName,
        "email": user.Email,
        "profilePictureUrl": user.ProfilePictureUrl,
        "gender": _genderToString(user.UserGender),
        "age": user.Age,
        "phoneNumber": user.PhoneNumber,
        "friends": user.Friends,
      });

      return ServiceResponse<bool>(data: true, success: true);
    } on Exception catch (err) {
      return ServiceResponse<bool>(
          data: false, message: err.toString(), success: false);
    }
  }

  @override
  Future<ServiceResponse<UserModel>> getUser(String id) async {
    try {
      final docSnapshot =
      await FIREBASE_FIRESTORE.collection("users").doc(id).get();

      if (docSnapshot.exists) {
        final user = UserModel.fromDocument(docSnapshot);
        return ServiceResponse<UserModel>(data: user, success: true);
      } else {
        return ServiceResponse<UserModel>(
            message: "User not found", success: false);
      }
    } on Exception catch (err) {
      return ServiceResponse<UserModel>(
          message: err.toString(), success: false);
    }
  }


  @override
  Future<ServiceResponse<List<UserModel>>> getAllUsers({int limit = 10, DocumentSnapshot? lastDocument}) async {
    try {
      Query query = FIREBASE_FIRESTORE.collection("users").limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        List<UserModel> users = [];

        for (var doc in querySnapshot.docs) {
          UserModel user = UserModel.fromDocument(doc);
          users.add(user);
        }

        return ServiceResponse<List<UserModel>>(
          data: users,
          success: true,
        );
      } else {
        return ServiceResponse<List<UserModel>>(
          message: "No users found",
          success: false,
        );
      }
    } catch (err) {
      return ServiceResponse<List<UserModel>>(
        message: err.toString(),
        success: false,
      );
    }
  }

  @override
  Future<ServiceResponse<List<UserModel>>> getFriends() {
    // TODO: implement getFriends
    throw UnimplementedError();
  }

  String _genderToString(Gender gender) {
    return gender == Gender.Male ? 'Male' : 'Female';
  }

  Gender _genderFromString(String gender) {
    return gender == 'Male' ? Gender.Male : Gender.Female;
  }
}
