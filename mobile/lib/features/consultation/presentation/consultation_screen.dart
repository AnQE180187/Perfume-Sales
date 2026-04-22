import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import 'widgets/ai_message_bubble.dart';
import 'widgets/user_message_bubble.dart';
import 'widgets/suggestion_chip.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  const ConsultationScreen({super.key});

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _drawerController;
  late final Animation<double> _drawerAnimation;
  late final AnimationController _pulseController;
  final FocusNode _focusNode = FocusNode();
  bool _showHistory = false;
  bool _isInputActive = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _drawerAnimation = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _focusNode.addListener(() {
      setState(() {
        _isInputActive = _focusNode.hasFocus;
      });
    });

    // Initialize after first frame so the provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _drawerController.dispose();
    _pulseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleHistory() {
    setState(() => _showHistory = !_showHistory);
    if (_showHistory) {
      _drawerController.forward();
    } else {
      _drawerController.reverse();
    }
  }

  void _closeHistory() {
    if (_showHistory) {
      setState(() => _showHistory = false);
      _drawerController.reverse();
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    // Scroll to bottom after state update
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatState = ref.watch(chatProvider);

    // Scroll to bottom when new message arrives
    ref.listen(chatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.ivoryBackground,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
        children: [
          // Main chat column
          Column(
            children: [
              // Safe area spacer for status bar
              SizedBox(height: MediaQuery.of(context).padding.top),
              //  Header
              _ChatHeader(
                onClose: () => Navigator.pop(context),
                onToggleHistory: _toggleHistory,
                pulseAnimation: _pulseController,
                onNewChat: () {
                  ref.read(chatProvider.notifier).startNewConversation();
                  _closeHistory();
                },
              ),

              // Message list
              Expanded(
                child: chatState.isInitializing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentGold,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(), // High-end feel
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 200), // Increased safe area for top/bottom scrolling
                        itemCount:
                            chatState.messages.length +
                            (chatState.isSending ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Typing indicator
                          if (index == chatState.messages.length) {
                            return const _TypingIndicator();
                          }
                          final message = chatState.messages[index];
                          return message.isAI
                              ? AiMessageBubble(message: message)
                              : UserMessageBubble(message: message);
                        },
                      ),
              ),

              //  Error banner
              if (chatState.sendError != null)
                _ErrorBanner(
                  message: chatState.sendError!,
                  onDismiss: () => ref.read(chatProvider.notifier).clearError(),
                ),

            ],
          ),

          // Floating Action Area (Chips + Input)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //  Dynamic suggestion chips (with sliding & glassmorphism)
                _AnimatedChipsArea(
                  isKeyboardVisible: MediaQuery.of(context).viewInsets.bottom > 0,
                  child: _DynamicChips(
                    hasRecommendations: chatState.messages.any(
                      (m) =>
                          m.isAI &&
                          m.recommendations != null &&
                          m.recommendations!.isNotEmpty,
                    ),
                    isSending: chatState.isSending,
                    onSend: (prompt) {
                      _messageController.text = prompt;
                      _sendMessage();
                    },
                  ),
                ),

                //  Input Area
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 24,
                  ),
                  child: SafeArea(
                    top: false,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.creamWhite.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _isInputActive
                              ? AppTheme.accentGold
                              : AppTheme.softTaupe.withValues(alpha: 0.5),
                          width: _isInputActive ? 1.5 : 1,
                        ),
                        boxShadow: [
                          if (_isInputActive)
                            BoxShadow(
                              color: AppTheme.accentGold.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                focusNode: _focusNode,
                                minLines: 1,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Nhắn nhủ điều bạn đang tìm kiếm...',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  hintStyle: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.mutedSilver.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: AppTheme.deepCharcoal,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: (chatState.isSending ||
                                      chatState.isInitializing)
                                  ? null
                                  : _sendMessage,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: chatState.isSending
                                      ? AppTheme.mutedSilver
                                      : AppTheme.accentGold,
                                  shape: BoxShape.circle,
                                  gradient: chatState.isSending
                                      ? null
                                      : const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppTheme.champagneGold,
                                            AppTheme.accentGold,
                                          ],
                                        ),
                                ),
                                child: chatState.isSending
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppTheme.primaryDb,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.auto_awesome,
                                        color: AppTheme.primaryDb,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrim overlay when drawer is open
          if (_showHistory)
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (context, child) => GestureDetector(
                onTap: _closeHistory,
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.3 * _drawerAnimation.value,
                  ),
                ),
              ),
            ),

          // Side drawer
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (context, child) {
              final drawerWidth = MediaQuery.of(context).size.width * 0.78;
              return Positioned(
                left: -drawerWidth + (drawerWidth * _drawerAnimation.value),
                top: 0,
                bottom: 0,
                width: drawerWidth,
                child: _ConversationDrawer(
                  conversations: chatState.conversations,
                  activeId: chatState.activeConversationId,
                  onSelect: (id) {
                    ref.read(chatProvider.notifier).selectConversation(id);
                    _closeHistory();
                  },
                  onDelete: (id) {
                    ref.read(chatProvider.notifier).deleteConversation(id);
                  },
                  onNewChat: () {
                    ref.read(chatProvider.notifier).startNewConversation();
                    _closeHistory();
                  },
                  onClose: _closeHistory,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ChatHeader extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onToggleHistory;
  final VoidCallback onNewChat;
  final Animation<double> pulseAnimation;

  const _ChatHeader({
    required this.onClose,
    required this.onToggleHistory,
    required this.onNewChat,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onToggleHistory,
            icon: const Icon(Icons.menu_rounded, color: AppTheme.deepCharcoal),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.getGoldGradient(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primaryDb,
                  size: 20,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.creamWhite, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withValues(alpha: 0.6 * pulseAnimation.value),
                                blurRadius: 4 * pulseAnimation.value,
                                spreadRadius: 2 * pulseAnimation.value,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI Specialist',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                Text(
                  l10n.chatStatusActive,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNewChat,
            icon: const Icon(Icons.add_comment_outlined, color: AppTheme.accentGold),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: AppTheme.mutedSilver),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_DustParticle> _particles = List.generate(
    12,
    (index) => _DustParticle(),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      children: _particles.map((p) {
                        final progress = (_controller.value + p.delay) % 1.0;
                        return Positioned(
                          left: 20 + p.xOffset * progress,
                          bottom: 20 + 40 * progress,
                          child: Opacity(
                            opacity: (1.0 - progress) * p.maxOpacity,
                            child: Container(
                              width: p.size,
                              height: p.size,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentGold,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentGold,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Specialist is crafting...',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accentGold.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DustParticle {
  final double delay = (new DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0;
  final double xOffset = (new DateTime.now().microsecondsSinceEpoch % 200 - 100) / 5.0;
  final double size = (new DateTime.now().microsecondsSinceEpoch % 3 + 1).toDouble();
  final double maxOpacity = (new DateTime.now().microsecondsSinceEpoch % 5 + 5) / 10.0;
  
  _DustParticle();
}

// ---------------------------------------------------------------------------
// Dynamic Suggestion Chips
// ---------------------------------------------------------------------------

class _AnimatedChipsArea extends StatelessWidget {
  final bool isKeyboardVisible;
  final Widget child;

  const _AnimatedChipsArea({
    required this.isKeyboardVisible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isKeyboardVisible ? 0.0 : 1.0,
        child: isKeyboardVisible
            ? const SizedBox(width: double.infinity, height: 0)
            : Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.ivoryBackground.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: child,
              ),
      ),
    );
  }
}

class _DynamicChips extends StatelessWidget {
  final bool hasRecommendations;
  final bool isSending;
  final void Function(String prompt) onSend;

  const _DynamicChips({
    required this.hasRecommendations,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final chips = hasRecommendations ? _contextChips : _defaultChips;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1), // Subtle glass effect
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: chips.map((c) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: isSending ? null : () => onSend(c.prompt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.creamWhite.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon, size: 14, color: AppTheme.accentGold),
                      const SizedBox(width: 8),
                      Text(
                        c.label,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static const _defaultChips = [
    _ChipData(
      Icons.casino_outlined,
      'Gợi ý bất ngờ',
      'Gợi ý cho tôi một mùi hương bất ngờ',
    ),
    _ChipData(
      Icons.attach_money,
      'Dưới 1 triệu',
      'Gợi ý nước hoa dưới 1 triệu đồng',
    ),
    _ChipData(
      Icons.nightlight_outlined,
      'Hương cho buổi tối',
      'Mùi hương phù hợp cho buổi tối',
    ),
    _ChipData(Icons.favorite_border, 'Quà tặng', 'Gợi ý nước hoa làm quà tặng'),
  ];

  static const _contextChips = [
    _ChipData(Icons.trending_down, 'Rẻ hơn', 'Gợi ý tương tự nhưng rẻ hơn'),
    _ChipData(Icons.spa_outlined, 'Ngọt hơn', 'Gợi ý mùi hương ngọt hơn'),
    _ChipData(Icons.work_outline, 'Đi làm', 'Gợi ý nước hoa phù hợp đi làm'),
    _ChipData(Icons.male, 'Nam tính hơn', 'Gợi ý nước hoa nam tính hơn'),
    _ChipData(Icons.female, 'Nữ tính hơn', 'Gợi ý nước hoa nữ tính hơn'),
  ];
}

class _ChipData {
  final IconData icon;
  final String label;
  final String prompt;
  const _ChipData(this.icon, this.label, this.prompt);
}

// ---------------------------------------------------------------------------
// Conversation Drawer (vertical side panel)
// ---------------------------------------------------------------------------

class _ConversationDrawer extends StatelessWidget {
  final List<ConversationSummary> conversations;
  final String? activeId;
  final void Function(String id) onSelect;
  final void Function(String id) onDelete;
  final VoidCallback onNewChat;
  final VoidCallback onClose;

  const _ConversationDrawer({
    required this.conversations,
    required this.activeId,
    required this.onSelect,
    required this.onDelete,
    required this.onNewChat,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      elevation: 20,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      child: Container(
        color: AppTheme.creamWhite,
        child: SafeArea(
          child: Column(
            children: [
              // Drawer header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 12, 16),
                child: Row(
                  children: [
                    Text(
                      l10n.chatHistoryTitle,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.mutedSilver,
                        size: 24,
                      ),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),

              // New chat button - Premium style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GestureDetector(
                  onTap: onNewChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.getGoldGradient(),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_comment_rounded,
                          size: 18,
                          color: AppTheme.primaryDb,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.newConsultationBtn,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppTheme.primaryDb,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Section label
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.recentJourneysTitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppTheme.mutedSilver,
                    ),
                  ),
                ),
              ),

              // Conversation list
              Expanded(
                child: conversations.isEmpty
                    ? _EmptyHistory()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24, top: 4),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) => _HistoryItem(
                          conv: conversations[index],
                          isActive: conversations[index].id == activeId,
                          onSelect: onSelect,
                          onDelete: onDelete,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ConversationSummary conv;
  final bool isActive;
  final void Function(String id) onSelect;
  final void Function(String id) onDelete;

  const _HistoryItem({
    required this.conv,
    required this.isActive,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, h:mm a').format(conv.updatedAt).toUpperCase();
    final preview = conv.lastMessageText.isNotEmpty
        ? conv.lastMessageText
        : 'Starting a new scent story...';

    return Dismissible(
      key: ValueKey(conv.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(conv.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: const Color(0xFFFF453A).withValues(alpha: 0.1),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF453A)),
      ),
      child: GestureDetector(
        onTap: () => onSelect(conv.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentGold.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? AppTheme.accentGold.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnails of recommended scents
              _HistoryThumbnails(images: conv.recommendedImages),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: isActive ? AppTheme.accentGold : AppTheme.mutedSilver,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preview,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                        height: 1.4,
                        color: AppTheme.deepCharcoal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryThumbnails extends StatelessWidget {
  final List<String> images;
  const _HistoryThumbnails({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.ivoryBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          size: 20,
          color: AppTheme.accentGold,
        ),
      );
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          for (int i = 0; i < images.length.clamp(0, 3); i++)
            Positioned(
              left: i * 8.0,
              top: i * 4.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_edu_rounded,
            size: 48,
            color: AppTheme.mutedSilver.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No past journeys found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppTheme.mutedSilver,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF453A).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF453A).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF453A), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: const Color(0xFFFF453A),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: Color(0xFFFF453A), size: 16),
          ),
        ],
      ),
    );
  }
}
