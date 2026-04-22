import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/address.dart';
import '../../providers/address_providers.dart';
import '../widgets/address_card.dart';
import 'address_form_screen.dart';

class AddressManagementScreen extends ConsumerStatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  ConsumerState<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState
    extends ConsumerState<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(addressListProvider.notifier).reload());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final addressesAsync = ref.watch(addressListProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.deepCharcoal),
        ),
        title: Text(
          l10n.addressBook.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: addressesAsync.when(
        loading: () => const _AddressLoadingSkeleton(),
        error: (error, _) => _AddressErrorState(
          message: error.toString(),
          onRetry: () => ref.read(addressListProvider.notifier).reload(),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return const _AddressEmptyState();
          }

          final defaultAddress = addresses.cast<Address?>().firstWhere(
            (item) => item?.isDefault == true,
            orElse: () => null,
          );
          final others = addresses.where((item) => !item.isDefault).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            children: [
              if (defaultAddress != null) ...[
                _SectionHeader(title: l10n.defaultAddressUpper),
                const SizedBox(height: 12),
                AddressCard(
                  address: defaultAddress,
                  selected: false,
                  onSelect: () {},
                  onSetDefault: null,
                  onEdit: () => _openForm(context, initialAddress: defaultAddress),
                  onDelete: () => _confirmDelete(context, ref, defaultAddress),
                ),
                const SizedBox(height: 32),
              ],
              if (others.isNotEmpty) ...[
                _SectionHeader(title: l10n.otherAddressesUpper),
                const SizedBox(height: 12),
                ...others.map((address) => AddressCard(
                      address: address,
                      selected: false,
                      onSelect: () {},
                      onSetDefault: () => _setDefault(context, ref, address.id),
                      onEdit: () => _openForm(context, initialAddress: address),
                      onDelete: () => _confirmDelete(context, ref, address),
                    )),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () => _openForm(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.deepCharcoal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.addNewAddressUpper,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Address? initialAddress}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddressFormScreen(initialAddress: initialAddress)),
    );
    ref.read(addressListProvider.notifier).reload();
  }

  Future<void> _setDefault(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(addressListProvider.notifier).setDefaultAddress(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Address address) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAddress.toUpperCase(), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Text(l10n.deleteAddressConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancelUpper)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete.toUpperCase(), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(addressListProvider.notifier).deleteAddress(address.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.addressDeleted)));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.mutedSilver,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _AddressLoadingSkeleton extends StatelessWidget {
  const _AddressLoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

class _AddressEmptyState extends StatelessWidget {
  const _AddressEmptyState();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on_outlined, size: 64, color: AppTheme.softTaupe),
          const SizedBox(height: 20),
          Text(
            l10n.noAddressesFound,
            style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addAddressHint,
            style: GoogleFonts.montserrat(color: AppTheme.mutedSilver),
          ),
        ],
      ),
    );
  }
}

class _AddressErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _AddressErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
