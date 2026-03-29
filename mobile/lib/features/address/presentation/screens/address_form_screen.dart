import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/address.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(addressFormProvider(initialAddress)).errorMessage ??
                  'Không thể lưu địa chỉ',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.of(context).pop(true);
    }

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.ivoryBackground,
        elevation: 0,
        title: Text(
          state.isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.deepCharcoal,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _DropdownField<AddressLabel>(
            label: 'Nhãn địa chỉ',
            value: state.label,
            items: AddressLabel.values,
            itemText: (label) => label.displayName,
            onChanged: (label) {
              if (label == null) return;
              notifier.setLabel(label);
            },
          ),
          _TextInput(
            label: 'Người nhận',
            initialValue: state.recipientName,
            onChanged: notifier.setRecipientName,
          ),
          _TextInput(
            label: 'Số điện thoại',
            initialValue: state.phone,
            keyboardType: TextInputType.phone,
            onChanged: notifier.setPhone,
          ),
          _DropdownField<int>(
            label: 'Tỉnh / Thành phố',
            value: state.provinceId,
            loading: state.loadingProvinces,
            items: state.provinces.map((item) => item.id).toList(),
            itemText: (id) {
              return state.provinces.firstWhere((item) => item.id == id).name;
            },
            onChanged: (id) {
              if (id == null) return;
              notifier.loadDistricts(id);
            },
          ),
          _DropdownField<int>(
            label: 'Quận / Huyện',
            value: state.districtId,
            loading: state.loadingDistricts,
            items: state.districts.map((item) => item.id).toList(),
            itemText: (id) {
              return state.districts.firstWhere((item) => item.id == id).name;
            },
            onChanged: (id) {
              if (id == null) return;
              notifier.loadWards(id);
              notifier.loadServices(id);
            },
          ),
          _DropdownField<String>(
            label: 'Phường / Xã',
            value: state.wardCode,
            loading: state.loadingWards,
            items: state.wards.map((item) => item.code).toList(),
            itemText: (code) {
              return state.wards.firstWhere((item) => item.code == code).name;
            },
            onChanged: (value) {
              if (value == null) return;
              notifier.setWardCode(value);
            },
          ),
          _DropdownField<int>(
            label: 'Dịch vụ vận chuyển',
            value: state.serviceId,
            loading: state.loadingServices,
            items: state.services.map((item) => item.id).toList(),
            itemText: (id) {
              return state.services.firstWhere((item) => item.id == id).name;
            },
            onChanged: (value) {
              if (value == null) return;
              notifier.setServiceId(value);
            },
          ),
          _TextInput(
            label: 'Địa chỉ chi tiết',
            initialValue: state.fullAddress,
            maxLines: 3,
            onChanged: notifier.setFullAddress,
          ),
          _TextInput(
            label: 'Ghi chú (không bắt buộc)',
            initialValue: state.note,
            maxLines: 2,
            onChanged: notifier.setNote,
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.errorMessage!,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.isSubmitting ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.deepCharcoal,
              minimumSize: const Size.fromHeight(52),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(state.isEditing ? 'Cập nhật địa chỉ' : 'Lưu địa chỉ'),
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemText;
  final ValueChanged<T?> onChanged;
  final bool loading;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemText,
    required this.onChanged,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        initialValue: items.contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemText(item), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: loading ? null : onChanged,
      ),
    );
  }
}

class _TextInput extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType keyboardType;

  const _TextInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _controller,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
