import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/api/api_client.dart';
import '../../../core/config/env.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../models/chat_models.dart';

class ChatService {
  final ApiClient apiClient;
  final SecureTokenStorage tokenStorage;
  io.Socket? _socket;

  ChatService({required this.apiClient, required this.tokenStorage});

  // ── REST API Methods ──────────────────────────────────────────

  Future<List<Conversation>> getConversations() async {
    final response = await apiClient.get('/chat/conversations');
    final data = response.data;
    if (data is List) {
      return data.map((e) => Conversation.fromJson(e)).toList();
    }
    return [];
  }

  Future<Conversation> getOrCreateConversation({
    required ConversationType type,
    String? otherUserId,
  }) async {
    final response = await apiClient.post('/chat/conversations', data: {
      'type': type.toJson(),
      if (otherUserId != null) 'otherUserId': otherUserId,
    });
    return Conversation.fromJson(response.data);
  }

  Future<List<ChatMessage>> getMessages({
    required String conversationId,
    String? cursor,
    int take = 50,
  }) async {
    final response = await apiClient.get(
      '/chat/messages',
      queryParameters: {
        'conversationId': conversationId,
        if (cursor != null) 'cursor': cursor,
        'take': take,
      },
    );
    final data = response.data;
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).map((e) => ChatMessage.fromJson(e)).toList();
    }
    return [];
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required MessageType type,
    required Map<String, dynamic> content,
  }) async {
    final response = await apiClient.post('/chat/messages', data: {
      'conversationId': conversationId,
      'type': type.toJson(),
      'content': content,
    });
    // The backend returns { message: ..., aiMessage: ... }
    return ChatMessage.fromJson(response.data['message']);
  }

  Future<ChatMessage> uploadImage({
    required String conversationId,
    required String filePath,
  }) async {
    final fileName = p.basename(filePath);
    final ext = p.extension(filePath).replaceAll('.', '');
    
    final formData = FormData.fromMap({
      'conversationId': conversationId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: MediaType('image', ext.isEmpty ? 'jpeg' : ext),
      ),
    });

    final response = await apiClient.post('/chat/messages/image', data: formData);
    return ChatMessage.fromJson(response.data['message']);
  }

  Future<List<Map<String, dynamic>>> getContacts({String? search}) async {
    final response = await apiClient.get('/chat/contacts', queryParameters: {
      if (search != null) 'search': search,
    });
    return List<Map<String, dynamic>>.from(response.data);
  }

  // ── WebSocket Methods ──────────────────────────────────────────

  void connectNamespace(String conversationId, Function(ChatMessage) onMessageReceived) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) return;

    final String socketUrl = '${EnvConfig.apiBaseUrl}/chat';

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Chat Socket connected');
      _socket!.emit('joinConversation', conversationId);
    });

    _socket!.on('message', (data) {
      debugPrint('New message via WS: $data');
      onMessageReceived(ChatMessage.fromJson(data));
    });

    _socket!.onDisconnect((_) => debugPrint('Chat Socket disconnected'));
    _socket!.onConnectError((err) => debugPrint('Chat Socket connect error: $err'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
