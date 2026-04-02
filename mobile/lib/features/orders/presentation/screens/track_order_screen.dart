import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_timeline.dart';
import '../widgets/tracking_map_card.dart';

class TrackOrderScreen extends ConsumerWidget {
  final String orderId;

  const TrackOrderScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(trackingProvider(orderId));

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(title: const Text('Track Order')),
      body: trackingAsync.when(
        data: (tracking) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(orderDetailProvider(orderId));
            ref.invalidate(trackingProvider(orderId));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                tracking.header,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tracking.etaText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              TrackingMapCard(label: tracking.mapLabel),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.softTaupe),
                ),
                child: OrderTimeline(steps: tracking.steps),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
