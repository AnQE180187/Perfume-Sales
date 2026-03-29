import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

/// Chat state — immutable snapshot kept by [ChatNotifier].
class ChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? sendError;

  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.sendError,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? sendError,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      sendError: clearError ? null : (sendError ?? this.sendError),
    );
  }
}

/// Manages the conversation list.
///
/// Keeps message list in memory. Replace [_service.sendMessage] calls
/// with a real API call once the backend is wired.
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _service;

  ChatNotifier(this._service)
    : super(
        ChatState(
          messages: [
            ChatMessage(
              isAI: true,
              text:
                  'Chào buổi tối. Tôi là chuyên gia mùi hương AI đồng hành cùng bạn. Hôm nay tôi có thể giúp bạn tìm ra mùi hương đặc trưng như thế nào?',
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Optimistically add user message
    final userMsg = ChatMessage(
      isAI: false,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      clearError: true,
    );

    try {
      final aiReply = await _service.sendMessage(trimmed);
      state = state.copyWith(
        messages: [...state.messages, aiReply],
        isSending: false,
      );
    } catch (error) {
      state = state.copyWith(isSending: false, sendError: error.toString());
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  void reset() {
    state = ChatState(
      messages: [
        ChatMessage(
          isAI: true,
          text:
              'Chào buổi tối. Tôi là chuyên gia mùi hương AI đồng hành cùng bạn. Hôm nay tôi có thể giúp bạn tìm ra mùi hương đặc trưng như thế nào?',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

final chatProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>(
  (ref) {
    return ChatNotifier(ref.read(chatServiceProvider));
  },
);
