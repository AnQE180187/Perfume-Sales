import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isSignIn = true;
  bool _showPassword = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleSocialLogin(Future<void> Function() loginFn) async {
    try {
      await loginFn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $e')));
      }
    }
  }

  Future<void> _handleContinue() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseProvideCredentials)));
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).login(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.accessDenied}: $e')));
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  
                  // Central 'L' Logo in Smoky Obsidian Glass
                  _buildGlassLogo(),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Chào mừng đến với\nPerfumeGPT',
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
                    'Trợ lý mùi hương AI dành riêng cho bạn',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7A7A7A),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Auth Mode Toggle
                  _buildAuthToggle(),

                  const SizedBox(height: 32),

                  // Neumorphic Email Input
                  _buildInputField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    hint: 'Địa chỉ email',
                    icon: Icons.mail_outline,
                  ),

                  const SizedBox(height: 20),

                  // Neumorphic Password Input
                  _buildInputField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    hint: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 16),

                   // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Quên mật khẩu?',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB8902E),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Obsidian Capsule Button
                  _buildObsidianButton(
                     text: 'Tiếp tục',
                     isLoading: authState.isLoading,
                     onPressed: _handleContinue,
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
                        onPressed: () => _handleSocialLogin(ref.read(authControllerProvider.notifier).signInWithGoogle),
                      ),
                      const SizedBox(width: 24),
                      _buildSocialButton(
                        icon: FontAwesomeIcons.facebookF,
                        color: const Color(0xFF1877F2),
                        onPressed: () => _handleSocialLogin(ref.read(authControllerProvider.notifier).signInWithFacebook),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
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

  Widget _buildGlassLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.85),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
             color: Colors.black.withOpacity(0.3),
             blurRadius: 10,
             offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          'L',
          style: GoogleFonts.playfairDisplay(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFF5F1ED),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthToggle() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE3).withOpacity(0.6), // Recessed toggle background
        borderRadius: BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDCD6D0),
            offset: Offset(2, 2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignIn = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _isSignIn ? const Color(0xFFFAF8F5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: _isSignIn ? const [
                    BoxShadow(color: Color(0xFFDCD6D0), offset: Offset(2, 2), blurRadius: 4),
                    BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
                  ] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Đăng nhập',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: _isSignIn ? FontWeight.w600 : FontWeight.w500,
                    color: _isSignIn ? const Color(0xFF2C2C2C) : const Color(0xFF999999),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.push('/register');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: !_isSignIn ? const Color(0xFFFAF8F5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(23),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Tạo tài khoản',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: !_isSignIn ? FontWeight.w600 : FontWeight.w500,
                    color: !_isSignIn ? const Color(0xFF2C2C2C) : const Color(0xFF999999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    final isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(20),
        // Neumorphic recessed effect
        boxShadow: isFocused 
          ? [
              // Golden glowing pulse
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ]
          : const [
              // Dark shadow bottom right
              BoxShadow(
                color: Color(0xFFE5DED5),
                offset: Offset(3, 3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
              // Light shadow top left
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
          obscureText: isPassword && !_showPassword,
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
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Icon(
                      _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
