import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_button.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/profile_edit_provider.dart';

/// Profile Edit Screen
///
/// Allows the user to update their personal information:
/// full name, phone number, gender, and date of birth.
/// Calls PATCH /users/me directly — no mock data.
class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
            body: const Center(child: Text('Vui lòng đăng nhập.')),
          );
        }
        return _ProfileEditForm(profile: profile);
      },
      loading: () => Scaffold(
        backgroundColor: AppTheme.ivoryBackground,
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.ivoryBackground,
        appBar: _buildAppBar(context),
        body: Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.ivoryBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        color: AppTheme.deepCharcoal,
      ),
      title: Text(
        'Chỉnh sửa hồ sơ',
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.deepCharcoal,
        ),
      ),
      centerTitle: true,
    );
  }
}

class _ProfileEditForm extends ConsumerStatefulWidget {
  final UserProfile profile;

  const _ProfileEditForm({required this.profile});

  @override
  ConsumerState<_ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<_ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;

  String? _selectedGender;
  DateTime? _selectedDob;

  static const _genderOptions = [
    ('male', 'Nam'),
    ('female', 'Nữ'),
    ('other', 'Khác'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _selectedGender = widget.profile.gender;
    _selectedDob = widget.profile.dateOfBirth;
    _dobController = TextEditingController(
      text: _selectedDob != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDob!)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('vi', 'VN'),
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(profileEditProvider.notifier)
          .save(
            fullName: _nameController.text,
            phone: _phoneController.text,
            gender: _selectedGender,
            dateOfBirth: _selectedDob?.toIso8601String(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hồ sơ đã được cập nhật',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            backgroundColor: AppTheme.accentGold,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cập nhật thất bại: $e',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(profileEditProvider);
    final isLoading = saveState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: isLoading ? null : () => Navigator.pop(context),
          color: AppTheme.deepCharcoal,
        ),
        title: Text(
          'CHỈNH SỬA HỒ SƠ',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarSection(avatarUrl: widget.profile.avatarUrl),
              const SizedBox(height: 48),
              
              _SectionLabel('THÔNG TIN CƠ BẢN'),
              const SizedBox(height: 24),
              AppInput(
                label: 'Tên hiển thị',
                hint: 'Họ và tên của bạn',
                controller: _nameController,
                prefixIcon: _GoldIcon(Icons.person_outline_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 20),
              AppInput(
                label: 'Địa chỉ Email',
                hint: widget.profile.email,
                readOnly: true,
                enabled: false,
                prefixIcon: _GoldIcon(Icons.alternate_email_rounded),
              ),
              const SizedBox(height: 20),
              AppInput(
                label: 'Số điện thoại',
                hint: 'Nhập số điện thoại mới',
                controller: _phoneController,
                prefixIcon: _GoldIcon(Icons.phone_iphone_rounded),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              
              const SizedBox(height: 40),
              _SectionLabel('CHI TIẾT THÊM'),
              const SizedBox(height: 24),
              _GenderSelector(
                selected: _selectedGender,
                options: _genderOptions,
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 24),
              AppInput(
                label: 'Ngày sinh nhật',
                hint: 'Chọn ngày sinh của bạn',
                controller: _dobController,
                readOnly: true,
                prefixIcon: _GoldIcon(Icons.cake_outlined),
                onTap: _pickDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.softTaupe),
              ),
              
              const SizedBox(height: 56),
              _PremiumSaveButton(
                onPressed: isLoading ? null : _save,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoldIcon extends StatelessWidget {
  final IconData icon;
  const _GoldIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Icon(icon, size: 20, color: AppTheme.accentGold),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final String? avatarUrl;

  const _AvatarSection({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.deepCharcoal,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: AppTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Icon(
          Icons.person_2_outlined,
          size: 44,
          color: AppTheme.softTaupe,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: AppTheme.accentGold,
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String? selected;
  final List<(String, String)> options;
  final ValueChanged<String?> onChanged;

  const _GenderSelector({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIỚI TÍNH',
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppTheme.mutedSilver,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: options
              .map(
                (opt) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _GenderChip(
                      label: opt.$2,
                      value: opt.$1,
                      isSelected: selected == opt.$1,
                      onTap: () =>
                          onChanged(selected == opt.$1 ? null : opt.$1),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.deepCharcoal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold.withValues(alpha: 0.5) : AppTheme.softTaupe.withValues(alpha: 0.3),
            width: isSelected ? 1 : 0.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.deepCharcoal,
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumSaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PremiumSaveButton({this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: onPressed == null ? [
            AppTheme.softTaupe.withValues(alpha: 0.5),
            AppTheme.softTaupe.withValues(alpha: 0.3),
          ] : [
            const Color(0xFFD4AF37),
            AppTheme.accentGold,
            const Color(0xFFFFDF00),
          ],
        ),
        boxShadow: onPressed == null ? [] : [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.deepCharcoal),
                  )
                : Text(
                    'LƯU THAY ĐỔI',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.deepCharcoal,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
