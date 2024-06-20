import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:meet_chat/core/models/UserModel.dart';

abstract class IDatabaseService {
  Future<ServiceResponse<bool>> createUser(String id, UserModel user);
}

class DatabaseService implements IDatabaseService {

  @override
  Future<ServiceResponse<bool>> createUser(String id, UserModel user) async {
    try {
      await FIREBASE_FIRESTORE
          .collection("users")
          .doc(id)
          .set({
        "username": user.Username,
        "firstName": user.FirstName,
        "lastName": user.LastName,
        "email": user.Email,
        "profilePictureUrl": user.ProfilePictureUrl,
        "gender": user.UserGender,
        "age": user.Age,
      });

      return ServiceResponse<bool>(data: true, success: true);
    } on Exception catch (err) {
      return ServiceResponse<bool>(data: false, message: err.toString(), success: false);
    }
  }
}
