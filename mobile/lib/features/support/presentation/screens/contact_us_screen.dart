import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../chat/providers/chat_providers.dart';
import '../../../chat/models/chat_models.dart';
import '../../../../l10n/app_localizations.dart';

class ContactUsScreen extends ConsumerWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.deepCharcoal, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.contactTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.supportChannels,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppTheme.mutedSilver,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactMethod(
              Icons.chat_bubble_outline_rounded,
              l10n.liveChat,
              l10n.responseTime5m,
              onTap: () async {
                final adminAsync = ref.read(adminContactProvider);
                adminAsync.whenData((admin) async {
                  if (admin != null) {
                    final conversation = await ref
                        .read(chatServiceProvider)
                        .getOrCreateConversation(
                          type: ConversationType.customerAdmin,
                          otherUserId: admin['id'],
                        );
                    context.push(AppRoutes.liveChatWithId(conversation.id,
                        title: 'CONCIERGE CHAT'));
                  }
                });
              },
            ),
            _buildContactMethod(
              Icons.mail_outline_rounded,
              l10n.sendEmail,
              'concierge@perfumegpt.com',
              onTap: () {},
            ),
            _buildContactMethod(
              Icons.phone_iphone_rounded,
              l10n.hotline247,
              '1900 8888 (${l10n.freeHotline})',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            Text(
              l10n.sendMessage,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppTheme.mutedSilver,
              ),
            ),
            const SizedBox(height: 16),
            _buildForm(l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.ivoryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.deepCharcoal, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.mutedSilver, size: 20),
        ],
      ),
    ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildTextField(l10n.fullName),
          const SizedBox(height: 16),
          _buildTextField(l10n.email),
          const SizedBox(height: 16),
          _buildTextField(l10n.message, maxLines: 4),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepCharcoal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.sendRequest.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppTheme.mutedSilver,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.ivoryBackground.withValues(alpha: 0.5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.accentGold, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
