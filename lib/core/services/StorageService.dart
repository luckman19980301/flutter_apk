import 'dart:io';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';

abstract class IStorageService {
  Future<ServiceResponse<String>> uploadFile(
      File? file, String userId, String fileName);
}

class StorageService implements IStorageService {

  @override
  Future<ServiceResponse<String>> uploadFile(
      File? file, String userId, String fileName) async {
    try {
      if (file == null) {
        return ServiceResponse(data: '', success: false, message: "No file provided.");
      }

      final directoryName = 'users/${userId}_photos';
      final storageRef = FIREBASE_STORAGE.ref().child(directoryName).child(userId + fileName);

      await storageRef.putFile(file);
      final fileUrl = await storageRef.getDownloadURL();

      return ServiceResponse(data: fileUrl, success: true);
    } catch (err) {
      return ServiceResponse(data: '', success: false, message: err.toString());
    }
  }
}
