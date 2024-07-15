import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/Message.dart';
import 'package:meet_chat/core/services/MessagingService.dart';

class ChatMessagesNotifier extends StateNotifier<List<Message>> {
  final IMessagingService messagingService;
  final String userId;
  final String recipientId;

  ChatMessagesNotifier(this.messagingService, this.userId, this.recipientId) : super([]) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final stream = messagingService.loadMessages(userId, recipientId);
    stream.listen((messages) {
      state = messages;
    });
  }
}

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, List<Message>, String>((ref, recipientId) {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final messagingService = ref.read(messagingServiceProvider);
  return ChatMessagesNotifier(messagingService, userId, recipientId);
});

final messagingServiceProvider = Provider<IMessagingService>((ref) {
  return INJECTOR<IMessagingService>();
});
