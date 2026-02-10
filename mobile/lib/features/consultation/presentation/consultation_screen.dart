import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';
import '../models/product_recommendation.dart';
import 'widgets/ai_message_bubble.dart';
import 'widgets/user_message_bubble.dart';
import 'widgets/suggestion_chip.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      isAI: true,
      text: 'Good evening. I\'m your personal scent sommelier. How may I assist you in discovering your signature fragrance today?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        isAI: false,
        text: _messageController.text,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      
      // Simulate AI response
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              isAI: true,
              text: 'An excellent choice. Woody notes provide a sophisticated depth perfect for the evening.',
              timestamp: DateTime.now(),
              productRecommendation: ProductRecommendation(
                id: '7',
                name: 'Oud Wood Intense',
                brand: 'Tom Ford',
                price: 295.00,
                imageUrl: 'https://images.unsplash.com/photo-1619994737967-d3e5e9478c85?w=800',
              ),
            ));
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppTheme.ivoryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.creamWhite,
              border: Border(
                bottom: BorderSide(color: AppTheme.softTaupe, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.primaryDb,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scent Sommelier',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ONLINE',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: AppTheme.mutedSilver,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.deepCharcoal),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return message.isAI
                    ? AiMessageBubble(message: message)
                    : UserMessageBubble(message: message);
              },
            ),
          ),

          // Quick Suggestions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SuggestionChip(
                    label: 'Surprise me',
                    icon: Icons.casino_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  SuggestionChip(
                    label: 'Under \$150',
                    icon: Icons.attach_money,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  SuggestionChip(
                    label: 'Evening scents',
                    icon: Icons.nightlight_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.creamWhite,
              border: Border(
                top: BorderSide(color: AppTheme.softTaupe, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.ivoryBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.softTaupe, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mic_none,
                            color: AppTheme.mutedSilver,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Describe your mood…',
                                border: InputBorder.none,
                                hintStyle: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.mutedSilver,
                                ),
                              ),
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: AppTheme.deepCharcoal,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: AppTheme.primaryDb,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
