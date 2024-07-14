import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/FileMetadata.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:mime/mime.dart';

abstract class IStorageService {
  Future<ServiceResponse<FileMetadata>> uploadFile(
      File? file, String directory, String fileName);

  Future<ServiceResponse<List<FileMetadata>>> getUserPhotos(String userId);

  Future<ServiceResponse<void>> deleteFile(String fileUrl);
}

class StorageService implements IStorageService {
  @override
  Future<ServiceResponse<FileMetadata>> uploadFile(
      File? file, String directory, String fileName) async {
    try {
      if (file == null) {
        return ServiceResponse(
            data: FileMetadata(url: '', type: '', size: 0, name: ''),
            success: false,
            message: "No file provided.");
      }

      final storageRef =
      FIREBASE_STORAGE.ref().child(directory).child(fileName);

      await storageRef.putFile(file);
      final fileUrl = await storageRef.getDownloadURL();
      final fileType = lookupMimeType(file.path) ?? 'application/octet-stream';

      final fileMetadata = FileMetadata(
        url: fileUrl,
        type: fileType,
        size: file.lengthSync(),
        name: fileName,
      );

      return ServiceResponse(data: fileMetadata, success: true);
    } catch (err) {
      return ServiceResponse(
          data: FileMetadata(url: '', type: '', size: 0, name: ''),
          success: false,
          message: err.toString());
    }
  }

  @override
  Future<ServiceResponse<List<FileMetadata>>> getUserPhotos(String userId) async {
    try {
      final directoryName = 'users/${userId}_photos';
      final storageRef = FIREBASE_STORAGE.ref().child(directoryName);

      final ListResult result = await storageRef.listAll();
      final List<FileMetadata> photoMetadata = await Future.wait(
        result.items.map((Reference ref) async {
          final url = await ref.getDownloadURL();
          final metadata = await ref.getMetadata();
          final fileType = metadata.contentType ?? 'application/octet-stream';
          final fileSize = metadata.size ?? 0;

          return FileMetadata(
            url: url,
            type: fileType,
            size: fileSize,
            name: ref.name,
          );
        }).toList(),
      );

      return ServiceResponse(data: photoMetadata, success: true);
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
