import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../services/stores_service.dart';

class BoutiquesScreen extends ConsumerStatefulWidget {
  const BoutiquesScreen({super.key});

  @override
  ConsumerState<BoutiquesScreen> createState() => _BoutiquesScreenState();
}

class _BoutiquesScreenState extends ConsumerState<BoutiquesScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storesAsync = ref.watch(publicStoresProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.creamWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppTheme.deepCharcoal,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 22,
              color: AppTheme.mutedSilver,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.boutiques,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.ivoryBackground,
      body: storesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 12),
              Text(l10n.unableLoadData, style: GoogleFonts.montserrat()),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.refresh(publicStoresProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (stores) {
          final visible = stores;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(publicStoresProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final s = visible[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.creamWhite.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.champagneGold.withValues(alpha: 0.28),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.champagneGold.withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppTheme.creamWhite.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: -2,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    leading: _buildLuxuryMarker(),
                    title: Text(
                      s.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        s.address ?? '',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.mutedSilver,
                          height: 1.35,
                        ),
                      ),
                    ),
                    trailing: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => _onViewStore(context, s),
                      child: Ink(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppTheme.champagneGold.withValues(
                              alpha: 0.45,
                            ),
                            width: 0.7,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.champagneGold.withValues(alpha: 0.18),
                              AppTheme.accentGold.withValues(alpha: 0.26),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLuxuryMarker() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.champagneGold.withValues(alpha: 0.65),
          width: 0.9,
        ),
        color: AppTheme.creamWhite,
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 14,
        color: AppTheme.accentGold,
      ),
    );
  }

  void _onViewStore(BuildContext context, Store s) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${s.name} — ${s.address ?? ''}')));
  }
}
