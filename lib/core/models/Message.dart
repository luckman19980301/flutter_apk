import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_chat/core/models/FileMetadata.dart';

class Message {
  final String text;
  final String senderId;
  final String recipientId;
  final String username;
  final String? userImage;
  final FileMetadata? file;
  final DateTime createdAt;
  final DocumentSnapshot documentSnapshot;

  Message({
    required this.text,
    required this.senderId,
    required this.recipientId,
    required this.username,
    this.userImage,
    this.file,
    required this.createdAt,
    required this.documentSnapshot,
  });

  factory Message.fromMap(Map<String, dynamic> map, DocumentSnapshot doc) {
    return Message(
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      recipientId: map['recipientId'] ?? '',
      username: map['username'] ?? 'Anonymous',
      userImage: map['userImage'],
      file: map['file'] != null ? FileMetadata.fromMap(map['file']) : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      documentSnapshot: doc,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'recipientId': recipientId,
      'username': username,
      'userImage': userImage,
      'file': file?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
