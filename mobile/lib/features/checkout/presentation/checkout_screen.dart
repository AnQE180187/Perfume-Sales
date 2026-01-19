import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'order_success_screen.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.orderAtelier.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 4, fontSize: 12),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                Text(l10n.yourSelection.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10)),
                const SizedBox(height: 24),
                const CheckoutItem(name: 'NOIR ÉLIXIR', price: '\$280', size: '100ML'),
                const CheckoutItem(name: 'LUMIÈRE D\'OR', price: '\$115', size: '30ML'),
                
                const SizedBox(height: 48),
                Text(l10n.shippingAtelier.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EVELYN VANCE',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '221B BAKER STREET, LONDON',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          l10n.change.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: AppTheme.accentGold),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                Text(l10n.paymentMethod.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card_outlined, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 20),
                      Text(
                        '•••• •••• •••• 1234',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.check_circle_outline, color: AppTheme.accentGold, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Total & Place Order
          Container(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.subtotal.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 10, 
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      '\$395',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.priorityShipping.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 10, 
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      l10n.complimentary.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: AppTheme.accentGold),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Theme.of(context).colorScheme.outline, thickness: 0.5),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalAcquisition.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
                    ),
                    Text(
                      '\$395',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                      );
                    },
                    child: Text(l10n.confirmOrder.toUpperCase()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutItem extends StatelessWidget {
  final String name;
  final String price;
  final String size;
  const CheckoutItem({super.key, required this.name, required this.price, required this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
            ),
            child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.outline, size: 30),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  size,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
          ),
        ],
      ).withFadedEdge(),
    );
  }
}

extension on Widget {
  Widget withFadedEdge() => this; // Placeholder for expansion
}
