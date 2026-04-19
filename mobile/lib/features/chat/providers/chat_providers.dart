import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../../../core/api/api_client.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  return ChatService(apiClient: apiClient, tokenStorage: tokenStorage);
});

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatService _service;
  final String _conversationId;

  ChatNotifier(this._service, this._conversationId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final messages = await _service.getMessages(conversationId: _conversationId);
      state = AsyncValue.data(messages.reversed.toList()); // Backend might return newest first, we want oldest first for UI usually, or depend on backend list order.
      // List message service typically returns desc order of creation. We want them in order for chat view.
      
      _service.connectNamespace(_conversationId, (msg) {
        if (msg.conversationId == _conversationId) {
          final currentMessages = state.asData?.value ?? [];
          // Avoid duplicate messages if already present
          if (!currentMessages.any((m) => m.id == msg.id)) {
            state = AsyncValue.data([...currentMessages, msg]);
          }
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await _service.sendMessage(
        conversationId: _conversationId,
        type: MessageType.text,
        content: {'text': text.trim()},
      );
      // We don't manually add it to state here because the WS will broadcast it back to us
      // or the backend call will return it. But WS is safer for sync.
    } catch (e) {
      // Handle error
    }
  }

  Future<void> sendImage(String filePath) async {
    try {
      await _service.uploadImage(
        conversationId: _conversationId,
        filePath: filePath,
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _service.disconnect();
    super.dispose();
  }
}

final chatMessagesProvider = StateNotifierProvider.family<ChatNotifier, AsyncValue<List<ChatMessage>>, String>((ref, conversationId) {
  final service = ref.watch(chatServiceProvider);
  return ChatNotifier(service, conversationId);
});

final adminContactProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final service = ref.watch(chatServiceProvider);
  final admins = await service.getContacts();
  if (admins.isNotEmpty) {
    return admins.first; // For now pick the first admin to chat with
  }
  return null;
});
