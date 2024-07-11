import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meet_chat/core/services/StorageService.dart';

class UploadPhotosWidget {
  final String userId;
  final VoidCallback onUploadComplete;
  final IStorageService _storageService = StorageService();

  UploadPhotosWidget({required this.userId, required this.onUploadComplete});

  Future<void> pickAndUploadImages(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {

        for (var file in pickedFiles) {
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final uploadResponse = await _storageService.uploadFile(File(file.path), userId, fileName);

          if (uploadResponse.success == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload ${file.name}: ${uploadResponse.message}')),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload completed')),
        );

        onUploadComplete();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }
}
