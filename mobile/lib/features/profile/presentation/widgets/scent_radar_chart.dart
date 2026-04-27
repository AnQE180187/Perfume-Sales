import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class ScentRadarChart extends StatelessWidget {
  final List<String> olfactoryTags;

  const ScentRadarChart({super.key, required this.olfactoryTags});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Categorization logic aligned with AiPreferencesScreen
    final Map<String, String> categoryToLabel = {
      'Floral': l10n.floral,
      'Woody': l10n.woody,
      'Citrus': l10n.citrus,
      'Spicy': l10n.spicy,
      'Musky': l10n.musky,
    };

    final Map<String, double> data = {
      for (var cat in categoryToLabel.keys) cat: 0.3,
    };

    final Map<String, List<String>> keywords = {
      'Woody': ['gỗ', 'đàn hương', 'wood', 'cedar', 'agarwood', 'trầm'],
      'Floral': ['hoa', 'rose', 'jasmine', 'floral', 'violet', 'nhài'],
      'Citrus': ['cam', 'chanh', 'citrus', 'lemon', 'bergamot', 'lime'],
      'Spicy': ['gia vị', 'spicy', 'tiêu', 'pepper', 'quế', 'ginger'],
      'Musky': ['xạ hương', 'musk', 'amber', 'vanilla', 'da thuộc'],
    };

    for (var category in data.keys) {
      for (var tag in olfactoryTags) {
        if (keywords[category]!.any((kw) => tag.toLowerCase().contains(kw.toLowerCase()))) {
          data[category] = (data[category]! + 0.18).clamp(0.2, 1.0);
        }
      }
    }

    final List<String> features = data.keys.toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle background glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          // Decorative "Molecule" particles
          Positioned(
            top: 40,
            right: 50,
            child: _buildParticle(8, 0.15),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            child: _buildParticle(12, 0.1),
          ),
          Positioned(
            top: 100,
            left: 60,
            child: _buildParticle(6, 0.2),
          ),
          RadarChart(
            RadarChartData(
              radarShape: RadarShape.circle,
              radarBorderData: const BorderSide(color: Colors.transparent),
              gridBorderData: BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.12), width: 1),
              tickBorderData: const BorderSide(color: Colors.transparent),
              ticksTextStyle: const TextStyle(color: Colors.transparent),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: GoogleFonts.montserrat(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
              ),
              getTitle: (index, angle) {
                final key = features[index % features.length];
                return RadarChartTitle(
                  text: (categoryToLabel[key] ?? key).toUpperCase(),
                );
              },
              dataSets: [
                RadarDataSet(
                  fillColor: AppTheme.accentGold.withValues(alpha: 0.3),
                  borderColor: AppTheme.accentGold,
                  entryRadius: 4,
                  dataEntries: features.map((f) => RadarEntry(value: data[f]!)).toList(),
                  borderWidth: 2.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.accentGold.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: opacity),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
