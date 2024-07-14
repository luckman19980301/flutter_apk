import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:meet_chat/core/models/Message.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/StorageService.dart';

abstract class IMessagingService {
  Future<ServiceResponse<void>> sendMessage(
      String senderId, String recipientId, String message);
  Future<ServiceResponse<void>> sendFileMessage(
      String senderId, String recipientId, File file);
  Stream<List<Message>> loadMessages(String senderId, String recipientId); // Update return type
}

class MessagingService implements IMessagingService {
  final FirebaseFirestore _firestore = FIREBASE_FIRESTORE;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final IStorageService _storageService = INJECTOR<IStorageService>();

  @override
  Future<ServiceResponse<void>> sendMessage(
      String senderId, String recipientId, String message) async {
    try {
      final chatId = _getChatId(senderId, recipientId);
      final chatDocRef = _firestore.collection('chats').doc(chatId);

      final newMessage = {
        'text': message,
        'createdAt': Timestamp.now(),
        'senderId': senderId,
        'recipientId': recipientId,
        'username': _auth.currentUser?.displayName ?? 'Anonymous',
        'userImage': _auth.currentUser?.photoURL,
        'file': null,
      };

      await chatDocRef.update({
        'messages': FieldValue.arrayUnion([newMessage]),
      }).catchError((error) async {
        if (error is FirebaseException && error.code == 'not-found') {
          await chatDocRef.set({
            'messages': [newMessage],
          });
        } else {
          throw error;
        }
      });

      return ServiceResponse<void>(data: null, success: true);
    } on Exception catch (err) {
      return ServiceResponse<void>(
          data: null, message: err.toString(), success: false);
    }
  }

  @override
  Future<ServiceResponse<void>> sendFileMessage(
      String senderId, String recipientId, File file) async {
    try {
      if (file.lengthSync() > 250 * 1024 * 1024) {
        return ServiceResponse<void>(message: "File size exceeds 250 MB.");
      }

      final chatId = _getChatId(senderId, recipientId);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final uploadResponse = await _storageService.uploadFile(
          file, 'chats/$chatId/files', fileName);

      if (uploadResponse.success == false) {
        return ServiceResponse<void>(message: uploadResponse.message ?? "File upload failed.");
      }

      final fileMetadata = uploadResponse.data!;
      final chatDocRef = _firestore.collection('chats').doc(chatId);

      final newMessage = {
        'text': null,
        'createdAt': Timestamp.now(),
        'senderId': senderId,
        'recipientId': recipientId,
        'username': _auth.currentUser?.displayName ?? 'Anonymous',
        'userImage': _auth.currentUser?.photoURL,
        'file': fileMetadata.toMap(),
      };

      await chatDocRef.update({
        'messages': FieldValue.arrayUnion([newMessage]),
      }).catchError((error) async {
        if (error is FirebaseException && error.code == 'not-found') {
          await chatDocRef.set({
            'messages': [newMessage],
          });
        } else {
          throw error;
        }
      });

      return ServiceResponse<void>(data: null, success: true);
    } on Exception catch (err) {
      return ServiceResponse<void>(
          data: null, message: err.toString(), success: false);
    }
  }

  @override
  Stream<List<Message>> loadMessages(String senderId, String recipientId) {
    final chatId = _getChatId(senderId, recipientId);
    return _firestore.collection('chats').doc(chatId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.data();
      if (data == null || !data.containsKey('messages')) {
        return [];
      }

      return List<Map<String, dynamic>>.from(data['messages'])
          .map((messageData) => Message.fromMap(messageData))
          .toList();
    });
  }

  String _getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }
}
