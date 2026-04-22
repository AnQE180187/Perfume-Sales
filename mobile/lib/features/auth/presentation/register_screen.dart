import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptedTerms = false;
  String? _errorMessage;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _fullNameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));

    _fullNameController.addListener(_clearError);
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
    _confirmPasswordController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    
    _pulseController.dispose();
    super.dispose();
  }

  void _showSocialNotSupported() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập mạng xã hội hiện chưa được hỗ trợ với API hiện tại.')),
    );
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = l10n.pleaseFillFields);
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Mật khẩu xác nhận không khớp.');
      return;
    }

    if (!_acceptedTerms) {
      setState(() => _errorMessage = l10n.pleaseAcceptTerms);
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).register(email: email, password: password, fullName: fullName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.registrationSuccessful)));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String message = '${l10n.accessDenied}: $e';
        
        if (e.toString().contains('already in use') || e.toString().contains('409')) {
          message = 'Email hoặc số điện thoại đã được sử dụng. Vui lòng chọn thông tin khác.';
        }
        
        setState(() => _errorMessage = message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Matte ivory-cream
      body: Stack(
        children: [
          // Background ambient glowing orbs & botanical art placeholder
          Positioned(
            top: -100,
            left: -50,
            child: _buildAmbientGlow(const Color(0xFFE8D5B7), size: 300),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: _buildAmbientGlow(const Color(0xFFD4AF37).withOpacity(0.5), size: 400),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // Title
                      Text(
                        'Tạo\nTài khoản',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2C2C),
                          height: 1.2,
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      Text(
                        'Gia nhập cộng đồng mùi hương tuyển chọn',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF7A7A7A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 48),

                      if (_errorMessage != null) _buildErrorBanner(_errorMessage!),

                      // Full Name Input
                      _buildInputField(
                        controller: _fullNameController,
                        focusNode: _fullNameFocus,
                        hint: 'Họ và tên',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 20),

                      // Email Input
                      _buildInputField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hint: 'Địa chỉ email',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      // Password Input
                      _buildInputField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hint: 'Mật khẩu',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        showPassword: _showPassword,
                        onTogglePassword: () => setState(() => _showPassword = !_showPassword),
                      ),

                      const SizedBox(height: 20),

                      // Confirm Password Input
                      _buildInputField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        hint: 'Xác nhận mật khẩu',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        showPassword: _showConfirmPassword,
                        onTogglePassword: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                      ),

                      const SizedBox(height: 24),

                      // Terms Checkbox
                      _buildTermsCheckbox(),

                      const SizedBox(height: 32),

                      // Obsidian Capsule Button
                      _buildObsidianButton(
                         text: 'Tạo tài khoản',
                         isLoading: authState.isLoading,
                         onPressed: _handleRegister,
                      ),

                      const SizedBox(height: 36),

                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE5E0D8))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'HOẶC TIẾP TỤC VỚI',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFAFAFAF),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE5E0D8))),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Social Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: FontAwesomeIcons.google,
                            color: const Color(0xFFDB4437),
                            onPressed: _showSocialNotSupported,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Footer Navigation
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF7A7A7A),
                          ),
                          children: [
                            const TextSpan(text: 'Đã có tài khoản? '),
                            TextSpan(
                              text: 'Đăng nhập',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C2C),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.pop(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                
                // Elegant Back Button
                Positioned(
                  top: 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8F5).withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFE5DED5), offset: Offset(2, 2), blurRadius: 4),
                          BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
                        ]
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF2C2C2C),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow(Color color, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool? showPassword,
    VoidCallback? onTogglePassword,
  }) {
    final isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isFocused 
          ? [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0xFFE5DED5),
                offset: Offset(3, 3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-3, -3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
        border: isFocused ? Border.all(color: const Color(0xFFD4AF37), width: 1.5) : null,
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: isPassword && !(showPassword ?? false),
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2C2C2C),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFB5B5B5),
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused ? const Color(0xFFB8902E) : const Color(0xFFB5B5B5),
              size: 20,
            ),
            suffixIcon: isPassword 
                ? GestureDetector(
                    onTap: onTogglePassword,
                    child: Icon(
                      (showPassword ?? false) ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFFB5B5B5),
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _acceptedTerms ? const Color(0xFFD4AF37) : const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Color(0xFFE5DED5), offset: Offset(2, 2), blurRadius: 4),
                BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
              ],
              border: _acceptedTerms ? Border.all(color: const Color(0xFFD4AF37), width: 1) : null,
            ),
            child: _acceptedTerms 
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7A7A7A),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Tôi đồng ý với '),
                  TextSpan(
                    text: 'Điều khoản dịch vụ',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB8902E),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' và '),
                  TextSpan(
                    text: 'Chính sách bảo mật',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB8902E),
                      decoration: TextDecoration.underline,
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

  Widget _buildObsidianButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2 + (_pulseController.value * 0.2)),
                blurRadius: 15 + (_pulseController.value * 5),
                spreadRadius: 2,
              ),
              const BoxShadow(
                 color: Color(0xFF1E1E1E),
                 offset: Offset(0, 4),
                 blurRadius: 8,
              ),
            ],
          ),
          child: Material(
            color: const Color(0xFF1E1E1E), // Obsidian
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(30),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD4AF37),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            text,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF5F1ED),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFFD4AF37),
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1515).withOpacity(0.9), // Deep dark red obsidian
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE57373).withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEF9A9A),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFFEBEE),
                letterSpacing: 0.2,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _errorMessage = null),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, color: Colors.white70, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE5DED5),
            offset: Offset(3, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: FaIcon(
              icon,
              size: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
