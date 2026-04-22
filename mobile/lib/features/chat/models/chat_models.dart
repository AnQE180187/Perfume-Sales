import 'dart:convert';

enum ConversationType {
  customerAdmin,
  customerAi,
  adminStaff,
  adminAi;

  String toJson() {
    return name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(0)}').toUpperCase();
  }

  static ConversationType fromJson(String json) => 
      ConversationType.values.firstWhere((e) => e.toJson() == json);
}

enum MessageType {
  text,
  image,
  productCard,
  system,
  aiRecommendation;

  String toJson() {
    return name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(0)}').toUpperCase();
  }

  static MessageType fromJson(String json) => 
      MessageType.values.firstWhere((e) => e.toJson() == json);
}

enum SenderType {
  user,
  ai;

  String toJson() => name.toUpperCase();
  static SenderType fromJson(String json) => 
      SenderType.values.firstWhere((e) => e.name.toUpperCase() == json);
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String? senderId;
  final SenderType senderType;
  final Map<String, dynamic> content;
  final MessageType type;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    this.senderId,
    required this.senderType,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      senderType: SenderType.fromJson(json['senderType']),
      content: json['content'] is String 
          ? jsonDecode(json['content']) 
          : Map<String, dynamic>.from(json['content']),
      type: MessageType.fromJson(json['type']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get text => content['text'] ?? '';
}

class Conversation {
  final String id;
  final ConversationType type;
  final List<ConversationParticipant> participants;
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.type,
    required this.participants,
    required this.messages,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      type: ConversationType.fromJson(json['type']),
      participants: (json['participants'] as List?)
              ?.map((e) => ConversationParticipant.fromJson(e))
              .toList() ??
          [],
      messages: (json['messages'] as List?)
              ?.map((e) => ChatMessage.fromJson(e))
              .toList() ??
          [],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ConversationParticipant {
  final String id;
  final String? userId;
  final String role; // CUSTOMER, ADMIN, STAFF, AI
  final Map<String, dynamic>? user;

  ConversationParticipant({
    required this.id,
    this.userId,
    required this.role,
    this.user,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id'],
      userId: json['userId'],
      role: json['role'],
      user: json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }
}
