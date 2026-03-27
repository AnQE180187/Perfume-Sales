import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class TrackingMapCard extends StatelessWidget {
  final String label;

  const TrackingMapCard({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: AppTheme.softTaupe),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF3ECE3), Color(0xFFEDE3D8)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 22,
                    left: 24,
                    child: _dot(const Color(0xFFB6923C), 14),
                  ),
                  Positioned(
                    bottom: 28,
                    right: 30,
                    child: _dot(const Color(0xFF12B76A), 18),
                  ),
                  Center(
                    child: Icon(
                      Icons.local_shipping_rounded,
                      size: 40,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _dot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}
