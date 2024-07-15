import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/core/models/ServiceResponse.dart';
import 'package:meet_chat/core/models/Message.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/StorageService.dart';

abstract class IMessagingService {
  Future<ServiceResponse<void>> sendMessage(String senderId, String recipientId, String message);
  Future<ServiceResponse<void>> sendFileMessage(String senderId, String recipientId, File file);
  Stream<List<Message>> loadMessages(String senderId, String recipientId, {int limit});
  Future<List<Message>> loadMoreMessages(String userId, String recipientId, Map<String, dynamic> lastMessageData, {int limit});
}

class MessagingService implements IMessagingService {
  final FirebaseFirestore _firestore = FIREBASE_FIRESTORE;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final IStorageService _storageService = INJECTOR<IStorageService>();

  @override
  Future<ServiceResponse<void>> sendMessage(String senderId, String recipientId, String message) async {
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
      return ServiceResponse<void>(data: null, message: err.toString(), success: false);
    }
  }

  @override
  Future<ServiceResponse<void>> sendFileMessage(String senderId, String recipientId, File file) async {
    try {
      if (file.lengthSync() > 250 * 1024 * 1024) {
        return ServiceResponse<void>(message: "File size exceeds 250 MB.");
      }

      final chatId = _getChatId(senderId, recipientId);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final uploadResponse = await _storageService.uploadFile(file, 'chats/$chatId/files', fileName);

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
      return ServiceResponse<void>(data: null, message: err.toString(), success: false);
    }
  }

  @override
  Stream<List<Message>> loadMessages(String senderId, String recipientId, {int limit = 20}) {
    final chatId = _getChatId(senderId, recipientId);
    return _firestore.collection('chats').doc(chatId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.data();
      if (data == null || !data.containsKey('messages')) {
        return [];
      }

      List<Map<String, dynamic>> messagesData = List<Map<String, dynamic>>.from(data['messages']);
      if (messagesData.length > limit) {
        messagesData = messagesData.sublist(0, limit);
      }

      return messagesData.map((messageData) {
        return Message.fromMap(messageData, snapshot);
      }).toList();
    });
  }

  @override
  Future<List<Message>> loadMoreMessages(String userId, String recipientId, Map<String, dynamic> lastMessageData, {int limit = 20}) async {
    final chatId = _getChatId(userId, recipientId);
    final doc = await _firestore.collection('chats').doc(chatId).get();
    final data = doc.data();

    if (data == null || !data.containsKey('messages')) {
      return [];
    }

    List<Map<String, dynamic>> messagesData = List<Map<String, dynamic>>.from(data['messages']);
    int lastIndex = messagesData.indexWhere((messageData) {
      final lastTimestamp = lastMessageData['createdAt'] as Timestamp;
      final messageTimestamp = messageData['createdAt'] as Timestamp;
      return messageTimestamp.compareTo(lastTimestamp) == 0;
    });

    if (lastIndex == -1 || lastIndex == messagesData.length - 1) {
      return [];
    }

    int endIndex = lastIndex + 1 + limit;
    if (endIndex > messagesData.length) {
      endIndex = messagesData.length;
    }

    List<Map<String, dynamic>> moreMessagesData = messagesData.sublist(lastIndex + 1, endIndex);

    return moreMessagesData.map((messageData) {
      return Message.fromMap(messageData, doc);
    }).toList();
  }

  String _getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }
}
