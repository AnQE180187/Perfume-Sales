import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tablet/presentation/tablet_staff_shell.dart';

/// Current tab index for StaffShell — accessible from any screen.
final staffTabIndexProvider = StateProvider<int>((ref) => 0);

class StaffShell extends ConsumerWidget {
  const StaffShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TabletStaffShell();
  }
}
