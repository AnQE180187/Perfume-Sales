import 'product_recommendation.dart';

class ChatMessage {
  final bool isAI;
  final String text;
  final DateTime timestamp;
  final ProductRecommendation? productRecommendation;

  ChatMessage({
    required this.isAI,
    required this.text,
    required this.timestamp,
    this.productRecommendation,
  });
}
