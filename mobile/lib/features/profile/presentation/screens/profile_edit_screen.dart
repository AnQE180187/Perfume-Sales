import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/profile_edit_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.editProfile)),
            body: Center(child: Text(l10n.pleaseLogin)),
          );
        }
        return _ProfileEditForm(profile: profile);
      },
      loading: () => Scaffold(
        backgroundColor: AppTheme.ivoryBackground,
        appBar: _buildAppBar(context, l10n),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.ivoryBackground,
        appBar: _buildAppBar(context, l10n),
        body: Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n) {
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
        l10n.editProfile,
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
  late final TextEditingController _minBudgetController;
  late final TextEditingController _maxBudgetController;


  String? _selectedGender;
  DateTime? _selectedDob;
  String? _error;

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
    _minBudgetController = TextEditingController(
      text: widget.profile.minBudget?.toStringAsFixed(0) ?? '',
    );
    _maxBudgetController = TextEditingController(
      text: widget.profile.maxBudget?.toStringAsFixed(0) ?? '',
    );

    
    _nameController.addListener(_clearError);
    _phoneController.addListener(_clearError);
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  void _updateControllers(UserProfile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phone ?? '';
    _selectedGender = profile.gender;
    _selectedDob = profile.dateOfBirth;
    if (_selectedDob != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDob!);
    } else {
      _dobController.text = '';
    }
    _minBudgetController.text = profile.minBudget?.toStringAsFixed(0) ?? '';
    _maxBudgetController.text = profile.maxBudget?.toStringAsFixed(0) ?? '';

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: l10n.birthdayHint,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _error = null);
      try {
        final updatedData = await ref.read(profileEditProvider.notifier).uploadAvatar(image.path);
        if (mounted && updatedData != null) {
          final updatedProfile = UserProfile.fromJson(updatedData);
          _updateControllers(updatedProfile);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cập nhật ảnh đại diện thành công'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            final errStr = e.toString().toLowerCase();
            if (errStr.contains('too large')) {
              _error = 'Kích thước ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn.';
            } else {
              _error = 'Không thể tải ảnh lên. Vui lòng thử lại sau.';
            }
          });
        }
      }
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = null);

    try {
      final updatedData = await ref.read(profileEditProvider.notifier).save(
            fullName: _nameController.text,
            phone: _phoneController.text,
            gender: _selectedGender,
            dateOfBirth: _selectedDob?.toIso8601String(),
            minBudget: double.tryParse(_minBudgetController.text),
            maxBudget: double.tryParse(_maxBudgetController.text),
          );

      
      if (mounted && updatedData != null) {
        final updatedProfile = UserProfile.fromJson(updatedData);
        _updateControllers(updatedProfile);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.profileUpdated,
              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppTheme.accentGold,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          String message = 'Cập nhật thất bại. Vui lòng kiểm tra lại thông tin.';
          if (e is DioException) {
            final data = e.response?.data;
            if (data is Map && data['message'] != null) {
              if (data['message'] is List) {
                message = (data['message'] as List).join(', ');
              } else {
                message = data['message'].toString();
              }
            }
          }
          _error = message;
        });
      }
    }
  }

  Widget _buildErrorBanner() {
    if (_error == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D0A0A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: GoogleFonts.montserrat(
                color: const Color(0xFFFFD1D1),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saveState = ref.watch(profileEditProvider);
    final isLoading = saveState.isLoading;

    final genderOptions = [
      ('male', l10n.male),
      ('female', l10n.female),
      ('other', l10n.other),
    ];

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
          l10n.editProfile.toUpperCase(),
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header & Avatar ---
              Consumer(
                builder: (context, ref, _) {
                  final profileAsync = ref.watch(profileProvider);
                  final profile = profileAsync.value ?? widget.profile;
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        _AvatarSection(
                          avatarUrl: profile.avatarUrl,
                          onTap: isLoading ? null : _changeAvatar,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                        Text(
                          profile.email,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: AppTheme.softTaupe,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildErrorBanner(),
              
              // --- Basic Information Card ---
              _PremiumCard(
                label: l10n.basicInfo,
                icon: Icons.badge_outlined,
                children: [
                  AppInput(
                    label: l10n.displayName,
                    hint: l10n.nameHint,
                    controller: _nameController,
                    prefixIcon: _GoldIcon(Icons.person_outline_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.enterName : null,
                  ),
                  const SizedBox(height: 20),
                  AppInput(
                    label: l10n.phone,
                    hint: l10n.phoneHint,
                    controller: _phoneController,
                    prefixIcon: _GoldIcon(Icons.phone_iphone_rounded),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),
                  _GenderSelector(
                    selected: _selectedGender,
                    options: genderOptions,
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                  const SizedBox(height: 20),
                  AppInput(
                    label: l10n.birthday,
                    hint: l10n.birthdayHint,
                    controller: _dobController,
                    readOnly: true,
                    prefixIcon: _GoldIcon(Icons.cake_outlined),
                    onTap: _pickDate,
                    suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.softTaupe),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // --- Budget Card ---
              _PremiumCard(
                label: 'NGÂN SÁCH DỰ KIẾN (VND)',
                icon: Icons.account_balance_wallet_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          label: 'Tối thiểu',
                          hint: '0',
                          controller: _minBudgetController,
                          prefixIcon: _GoldIcon(Icons.money_off_rounded),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInput(
                          label: 'Tối đa',
                          hint: '10.000.000',
                          controller: _maxBudgetController,
                          prefixIcon: _GoldIcon(Icons.attach_money_rounded),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
                            const SizedBox(height: 24),

              // --- Security Section ---
              _SectionLabel('BẢO MẬT & XÁC THỰC'),
              const SizedBox(height: 16),
              _SecurityCard(
                title: 'Đổi mật khẩu',
                subtitle: 'Tài khoản đang được bảo vệ',
                icon: Icons.shield_outlined,
                buttonLabel: 'Đổi mật khẩu',
                onPressed: () => _showChangePasswordDialog(context),
              ),
              if (!widget.profile.isEmailVerified) ...[
                const SizedBox(height: 16),
                _SecurityCard(
                  title: 'Xác thực Email',
                  subtitle: 'Email chưa xác thực. (Tùy chọn)',
                  icon: Icons.mark_email_unread_outlined,
                  buttonLabel: 'Gửi email xác thực',
                  isSecondary: true,
                  onPressed: () async {
                    try {
                      await ref.read(authControllerProvider.notifier).resendVerification();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã gửi email xác thực. Vui lòng kiểm tra hộp thư.')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gửi email thất bại: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
              
              const SizedBox(height: 48),
              _PremiumSaveButton(
                onPressed: isLoading ? null : _save,
                isLoading: isLoading,
                label: l10n.saveChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChangePasswordSheet(),
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

class _PremiumCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Widget> children;

  const _PremiumCard({
    required this.label,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: AppTheme.accentGold),
              ),
              const SizedBox(width: 12),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppTheme.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback? onTap;
  final bool isLoading;

  const _AvatarSection({this.avatarUrl, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGold.withValues(alpha: 0.8),
                    AppTheme.accentGold.withValues(alpha: 0.2),
                    AppTheme.accentGold.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accentGold,
                          ),
                        )
                      : avatarUrl != null
                          ? Image.network(
                              avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                ),
              ),
            ),
            if (!isLoading)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.deepCharcoal, Color(0xFF333333)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: AppTheme.accentGold,
                ),
              ),
          ],
        ),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gender,
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
  final String label;

  const _PremiumSaveButton({this.onPressed, required this.isLoading, required this.label});

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
                    label,
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

class _SecurityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isSecondary;

  const _SecurityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonLabel,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.softTaupe.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentGold, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  color: AppTheme.softTaupe,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              color: AppTheme.deepCharcoal,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSecondary ? Colors.transparent : AppTheme.accentGold.withValues(alpha: 0.8),
                foregroundColor: isSecondary ? AppTheme.accentGold : AppTheme.deepCharcoal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isSecondary ? BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.5)) : BorderSide.none,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSecondary) ...[
                    const Icon(Icons.send_rounded, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    buttonLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đổi mật khẩu thất bại: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.ivoryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.softTaupe.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'ĐỔI MẬT KHẨU',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.accentGold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nếu bạn đăng nhập bằng Google, bạn không cần đổi mật khẩu tại đây. Hãy quản lý tại trang cá nhân Google.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppTheme.deepCharcoal,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            AppInput(
              label: 'Mật khẩu hiện tại',
              controller: _oldPasswordController,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppTheme.accentGold),
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null,
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Mật khẩu mới',
              controller: _newPasswordController,
              obscureText: true,
              prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20, color: AppTheme.accentGold),
              validator: (v) => v!.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null,
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Xác nhận mật khẩu mới',
              controller: _confirmPasswordController,
              obscureText: true,
              prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20, color: AppTheme.accentGold),
              validator: (v) => v != _newPasswordController.text ? 'Mật khẩu không khớp' : null,
            ),
            const SizedBox(height: 40),
            _PremiumSaveButton(
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
              label: 'CẬP NHẬT MẬT KHẨU',
            ),
          ],
        ),
      ),
    );
  }
}

