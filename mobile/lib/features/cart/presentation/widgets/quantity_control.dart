import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';

class QuantityControl extends ConsumerWidget {
  final CartItem item;

  const QuantityControl({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            context,
            Icons.remove,
            () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity - 1),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
          ),
          _buildButton(
            context,
            Icons.add,
            () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
