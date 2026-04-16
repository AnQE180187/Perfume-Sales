import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/pos_provider.dart';
import '../../tablet/presentation/tablet_pos_gallery.dart';

class StaffPosScreen extends ConsumerWidget {
  const StaffPosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posState = ref.watch(posProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Rich deep black
      body: Stack(
        children: [
          const TabletPosGallery(),
          if (posState.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
