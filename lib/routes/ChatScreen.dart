import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/FileMetadata.dart';
import 'package:meet_chat/core/models/Message.dart';
import 'package:meet_chat/core/services/MessagingService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends ConsumerStatefulWidget {
  static const String route = "chat";
  final String recipientId;

  const ChatScreen({super.key, required this.recipientId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
    _scrollToBottom();
  }

  Future<void> _pickAndSendFile() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await _sendFile(file);
      _scrollToBottom();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
            child: StreamBuilder<List<Message>>(
              stream: _messagingService.loadMessages(FirebaseAuth.instance.currentUser!.uid, widget.recipientId),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final message = messages[index];
                    return ChatMessage(
                      message: message.text,
                      username: message.username,
                      userImage: message.userImage,
                      fileMetadata: message.file,
                      isMe: message.senderId == FirebaseAuth.instance.currentUser?.uid,
                      timestamp: message.createdAt,
                      key: ValueKey(index),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.pinkAccent),
                  onPressed: _pickAndSendFile,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Send a message...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
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
  final FileMetadata? fileMetadata;
  final bool isMe;
  final DateTime timestamp;

  const ChatMessage({
    this.message,
    required this.username,
    this.userImage,
    this.fileMetadata,
    required this.isMe,
    required this.timestamp,
    required Key key,
  }) : super(key: key);

  bool _isImageFile(String type) {
    return type.startsWith('image/');
  }

  void _showPhotoDialog(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeText = DateTime.now().difference(timestamp).inHours < 24
        ? timeago.format(timestamp)
        : '${timestamp.day}/${timestamp.month}/${timestamp.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              backgroundImage: userImage != null ? NetworkImage(userImage!) : null,
              child: userImage == null ? Text(username[0]) : null,
            ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: isMe ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(12),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.black : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      message!,
                      style: TextStyle(
                        color: isMe ? Colors.black : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                    ),
                  ),
                if (fileMetadata != null) ...[
                  const SizedBox(height: 8),
                  _isImageFile(fileMetadata!.type)
                      ? GestureDetector(
                    onTap: () => _showPhotoDialog(context, fileMetadata!.url),
                    child: Container(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          fileMetadata!.url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      : GestureDetector(
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
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: userImage != null ? NetworkImage(userImage!) : null,
                child: userImage == null ? Text(username[0]) : null,
              ),
            ),
        ],
      ),
    );
  }
}
