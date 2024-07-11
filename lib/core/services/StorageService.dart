import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';

abstract class IStorageService {
  Future<ServiceResponse<String>> uploadFile(
      File? file, String userId, String fileName);

  Future<ServiceResponse<List<String>>> getUserPhotos(String userId);

  Future<ServiceResponse<void>> deleteFile(String fileUrl);
}

class StorageService implements IStorageService {
  @override
  Future<ServiceResponse<String>> uploadFile(
      File? file, String userId, String fileName) async {
    try {
      if (file == null) {
        return ServiceResponse(
            data: '', success: false, message: "No file provided.");
      }

      final directoryName = 'users/${userId}_photos';
      final storageRef =
          FIREBASE_STORAGE.ref().child(directoryName).child(userId + fileName);

      await storageRef.putFile(file);
      final fileUrl = await storageRef.getDownloadURL();

      return ServiceResponse(data: fileUrl, success: true);
    } catch (err) {
      return ServiceResponse(data: '', success: false, message: err.toString());
    }
  }

  @override
  Future<ServiceResponse<List<String>>> getUserPhotos(String userId) async {
    try {
      final directoryName = 'users/${userId}_photos';
      final storageRef = FIREBASE_STORAGE.ref().child(directoryName);

      final ListResult result = await storageRef.listAll();
      final List<String> photoUrls = await Future.wait(
        result.items.map((Reference ref) => ref.getDownloadURL()).toList(),
      );

      return ServiceResponse(data: photoUrls, success: true);
    } catch (err) {
      return ServiceResponse(data: [], success: false, message: err.toString());
    }
  }

  @override
  Future<ServiceResponse<void>> deleteFile(String fileUrl) async {
    try {
      final Reference storageRef = FIREBASE_STORAGE.refFromURL(fileUrl);
      await storageRef.delete();

      return ServiceResponse(success: true);
    } catch (err) {
      return ServiceResponse(success: false, message: err.toString());
    }
  }
}
