import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brightness = Theme.of(context).brightness;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.neuralArchitect.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            letterSpacing: 6,
            fontSize: 12,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getLuxuryGradient(brightness)),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                children: [
                   _AIBubble(
                    message: l10n.welcomeMessage,
                  ),
                  const _UserBubble(
                    message: "I want a scent that captures the essence of a midnight library in London.",
                  ),
                  const _AIBubble(
                    message: "A sophisticated choice. We should layer aged Parchment accords with hints of Smoky Lapsang Souchong and a heart of Antique Mahogany. Let me formulate this molecular profile for you...",
                  ),
                ],
              ),
            ),
            
            // Refined Chat Input
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 120),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.montserrat(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: l10n.describeVision.toUpperCase(),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintStyle: GoogleFonts.montserrat(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), 
                            fontSize: 11, 
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIBubble extends StatelessWidget {
  final String message;
  const _AIBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.webhook_rounded, color: Theme.of(context).primaryColor, size: 14),
              const SizedBox(width: 8),
              Text(
                l10n.neuralArchitect.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 9, 
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 1)),
            ),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
          ),
          child: Text(
            message,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              letterSpacing: 0.5,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
