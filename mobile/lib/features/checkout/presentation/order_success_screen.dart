import 'package:flutter/material.dart';

import 'package:perfume_gpt_app/l10n/app_localizations.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome, 
                color: Theme.of(context).primaryColor, 
                size: 64,
              ),
              const SizedBox(height: 64),
              Text(
                l10n.acquisitionComplete.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.orderCodified.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor, width: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    l10n.returnToAtelier.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
