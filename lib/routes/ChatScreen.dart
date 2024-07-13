import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/MessagingService.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static const String route = "chat";
  final String recipientId;

  const ChatScreen({super.key, required this.recipientId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final IMessagingService _messagingService = INJECTOR<IMessagingService>();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in
      return;
    }

    final message = _messageController.text.trim();
    _messageController.clear();

    await _messagingService.sendMessage(user.uid, widget.recipientId, message);
  }

  Future<void> _pickAndSendFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await _sendFile(file);
    }
  }

  Future<void> _sendFile(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in
      return;
    }

    await _messagingService.sendFileMessage(user.uid, widget.recipientId, file);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: "Chat screen",
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _messagingService.loadMessages(FirebaseAuth.instance.currentUser!.uid, widget.recipientId),
              builder: (ctx, chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!chatSnapshot.hasData || chatSnapshot.data == null || !(chatSnapshot.data!.data() as Map<String, dynamic>).containsKey('messages')) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = List<Map<String, dynamic>>.from((chatSnapshot.data!.data() as Map<String, dynamic>)['messages']);

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final messageData = messages[index];
                    return ChatMessage(
                      messageData['text'],
                      messageData['username'],
                      messageData['userImage'],
                      messageData['fileUrl'],
                      messageData['senderId'] == FirebaseAuth.instance.currentUser?.uid,
                      key: ValueKey(index),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.pinkAccent),
                  onPressed: _pickAndSendFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pinkAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String? message;
  final String username;
  final String? userImage;
  final String? fileUrl;
  final bool isMe;

  const ChatMessage(
      this.message,
      this.username,
      this.userImage,
      this.fileUrl,
      this.isMe, {
        required Key key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          CircleAvatar(
            backgroundImage: userImage != null
                ? NetworkImage(userImage!)
                : null,
            child: userImage == null ? Text(username[0]) : null,
          ),
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[300] : Theme.of(context).secondaryHeaderColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe
                        ? Colors.black
                        : Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.color
                ),
              ),
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(
                    color: isMe
                        ? Colors.black
                        : Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.color,
                  ),
                  textAlign: isMe ? TextAlign.end : TextAlign.start,
                ),
              if (fileUrl != null)
                GestureDetector(
                  onTap: () {
                    // Handle file download or open
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_present, color: Colors.blue),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'File',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
