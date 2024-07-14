import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_chat/core/models/FileMetadata.dart';

class Message {
  final String? text;
  final String senderId;
  final String recipientId;
  final String username;
  final String? userImage;
  final DateTime createdAt;
  final FileMetadata? file;

  Message({
    this.text,
    required this.senderId,
    required this.recipientId,
    required this.username,
    this.userImage,
    required this.createdAt,
    this.file,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      text: data['text'] as String?,
      senderId: data['senderId'] as String,
      recipientId: data['recipientId'] as String,
      username: data['username'] as String,
      userImage: data['userImage'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      file: data['file'] != null ? FileMetadata.fromMap(data['file']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'recipientId': recipientId,
      'username': username,
      'userImage': userImage,
      'createdAt': createdAt,
      'file': file?.toMap(),
    };
  }
}
