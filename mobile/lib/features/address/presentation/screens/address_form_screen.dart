import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/bottom_sheet_picker.dart';
import '../../models/address.dart';
import '../../models/address_form_state.dart';
import '../../providers/address_providers.dart';

class AddressFormScreen extends ConsumerWidget {
  final Address? initialAddress;

  const AddressFormScreen({super.key, this.initialAddress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressFormProvider(initialAddress));
    final notifier = ref.read(addressFormProvider(initialAddress).notifier);

    Future<void> onSubmit() async {
      final ok = await notifier.submit();
      if (!context.mounted) return;

      if (!ok) {
        final message = ref
            .read(addressFormProvider(initialAddress))
            .errorMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
        return;
      }

      Navigator.of(context).pop(true);
    }

    Future<void> pickProvince() async {
      final selected = await showBottomSheetPicker<int>(
        context: context,
        title: 'Chọn Tỉnh / Thành phố',
        items: state.provinces
            .map((item) => PickerItem(value: item.id, label: item.name))
            .toList(),
        selected: state.provinceId,
      );
      if (selected != null) {
        await notifier.loadDistricts(selected);
      }
    }

    Future<void> pickDistrict() async {
      if (state.provinceId == null) return;
      final selected = await showBottomSheetPicker<int>(
        context: context,
        title: 'Chọn Quận / Huyện',
        items: state.districts
            .map((item) => PickerItem(value: item.id, label: item.name))
            .toList(),
        selected: state.districtId,
      );
      if (selected != null) {
        await notifier.loadWards(selected);
        await notifier.loadServices(selected);
      }
    }

    Future<void> pickWard() async {
      if (state.districtId == null) return;
      final selected = await showBottomSheetPicker<String>(
        context: context,
        title: 'Chọn Phường / Xã',
        items: state.wards
            .map((item) => PickerItem(value: item.code, label: item.name))
            .toList(),
        selected: state.wardCode,
      );
      if (selected != null) {
        notifier.setWardCode(selected);
      }
    }

    Future<void> pickService() async {
      if (state.services.isEmpty) return;
      final selected = await showBottomSheetPicker<int>(
        context: context,
        title: 'Chọn dịch vụ vận chuyển',
        items: state.services
            .map((item) => PickerItem(value: item.id, label: item.name))
            .toList(),
        selected: state.serviceId,
      );
      if (selected != null) {
        notifier.setServiceId(selected);
      }
    }

    final provinceName = _nameOfProvince(state);
    final districtName = _nameOfDistrict(state);
    final wardName = _nameOfWard(state);
    final serviceName = _nameOfService(state);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.close_rounded,
            color: AppTheme.deepCharcoal,
            size: 20,
          ),
        ),
        title: Text(
          (state.isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới').toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppTheme.deepCharcoal,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Phân loại'),
            _LabelSelector(selected: state.label, onChanged: notifier.setLabel),
            const SizedBox(height: 32),
            
            _SectionTitle(title: 'Người nhận'),
            AppInput(
              label: 'Thanh toán',
              hint: 'Tên người nhận',
              initialValue: state.recipientName,
              errorText: state.errorOf('recipientName'),
              onChanged: notifier.setRecipientName,
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Liên hệ',
              hint: 'Số điện thoại',
              initialValue: state.phone,
              errorText: state.errorOf('phone'),
              keyboardType: TextInputType.phone,
              onChanged: notifier.setPhone,
            ),
            const SizedBox(height: 32),

            _SectionTitle(title: 'Vị trí'),
            AppInput(
              label: 'Tỉnh / Thành phố',
              initialValue: provinceName,
              errorText: state.errorOf('provinceId'),
              readOnly: true,
              onTap: pickProvince,
              onChanged: (_) {},
              suffixIcon: state.loadingProvinces
                  ? const _LoadingSmall()
                  : const Icon(Icons.expand_more_rounded, size: 18),
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Quận / Huyện',
              initialValue: districtName,
              errorText: state.errorOf('districtId'),
              readOnly: true,
              enabled: state.provinceId != null,
              onTap: pickDistrict,
              onChanged: (_) {},
              suffixIcon: state.loadingDistricts
                  ? const _LoadingSmall()
                  : const Icon(Icons.expand_more_rounded, size: 18),
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Phường / Xã',
              initialValue: wardName,
              errorText: state.errorOf('wardCode'),
              readOnly: true,
              enabled: state.districtId != null,
              onTap: pickWard,
              onChanged: (_) {},
              suffixIcon: state.loadingWards
                  ? const _LoadingSmall()
                  : const Icon(Icons.expand_more_rounded, size: 18),
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Địa chỉ cụ thể',
              hint: 'Số nhà, tên đường...',
              initialValue: state.detailAddress,
              errorText: state.errorOf('detailAddress'),
              maxLines: 2,
              onChanged: notifier.setDetailAddress,
            ),
            const SizedBox(height: 32),

            _SectionTitle(title: 'Tùy chọn khác'),
            AppInput(
              label: 'Dịch vụ GHN',
              initialValue: serviceName,
              readOnly: true,
              enabled: state.districtId != null,
              onTap: pickService,
              onChanged: (_) {},
              suffixIcon: state.loadingServices
                  ? const _LoadingSmall()
                  : const Icon(Icons.expand_more_rounded, size: 18),
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Ghi chú',
              hint: 'Chỉ dẫn giao hàng...',
              initialValue: state.note,
              maxLines: 2,
              textInputAction: TextInputAction.done,
              onChanged: notifier.setNote,
            ),
            const SizedBox(height: 16),
            Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.accentGold,
                title: Text(
                  'Đặt làm địa chỉ mặc định',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                value: state.isDefault,
                onChanged: notifier.setDefaultAddress,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: FilledButton(
            onPressed: state.canSubmit && !state.isSubmitting ? onSubmit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.deepCharcoal,
              disabledBackgroundColor: AppTheme.softTaupe,
              disabledForegroundColor: AppTheme.mutedSilver,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    state.isEditing ? 'Cập nhật địa chỉ' : 'Lưu địa chỉ',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _nameOfProvince(AddressFormState state) {
    final id = state.provinceId;
    if (id == null) return '';
    for (final item in state.provinces) {
      if (item.id == id) return item.name;
    }
    return '';
  }

  String _nameOfDistrict(AddressFormState state) {
    final id = state.districtId;
    if (id == null) return '';
    for (final item in state.districts) {
      if (item.id == id) return item.name;
    }
    return '';
  }

  String _nameOfWard(AddressFormState state) {
    final code = state.wardCode;
    if (code == null) return '';
    for (final item in state.wards) {
      if (item.code == code) return item.name;
    }
    return '';
  }

  String _nameOfService(AddressFormState state) {
    final id = state.serviceId;
    if (id == null) return '';
    for (final item in state.services) {
      if (item.id == id) return item.name;
    }
    return '';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppTheme.accentGold,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _LabelSelector extends StatelessWidget {
  final AddressLabel selected;
  final ValueChanged<AddressLabel> onChanged;

  const _LabelSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AddressLabel.values.map((label) {
        final active = selected == label;
        IconData icon;
        switch (label) {
          case AddressLabel.home: icon = Icons.home_outlined; break;
          case AddressLabel.office: icon = Icons.work_outline_rounded; break;
          case AddressLabel.gift: icon = Icons.card_giftcard_rounded; break;
        }
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: label == AddressLabel.gift ? 0 : 12),
            child: InkWell(
              onTap: () => onChanged(label),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: active ? AppTheme.deepCharcoal : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? AppTheme.deepCharcoal : AppTheme.softTaupe.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: active ? [
                    BoxShadow(
                      color: AppTheme.deepCharcoal.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      icon, 
                      size: 20, 
                      color: active ? Colors.white : AppTheme.mutedSilver
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label.displayName,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppTheme.mutedSilver,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LoadingSmall extends StatelessWidget {
  const _LoadingSmall();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 14,
      height: 14,
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGold),
      ),
    );
  }
}
